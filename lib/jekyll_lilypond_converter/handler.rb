module JekyllLilyPondConverter
  class Handler
    def initialize(content:, naming_policy:, image_format:, site_manager:, static_file_builder:)
      @content = content
      @naming_policy = naming_policy
      @image_format = image_format
      @site_manager = site_manager
      @static_file_builder = static_file_builder
    end

    def execute
      ensure_valid_image_format

      lilies.each do |lily|
        write_lily_code_file(lily)
        has_audio = generate_lily_image(lily)
        add_lily_image_to_site(lily, has_audio)
        replace_snippet_with_image_link(lily, has_audio)
      end
      content
    end

    private
    attr_reader :content, :naming_policy, :image_format, :site_manager, :static_file_builder

    def ensure_valid_image_format
      unless ["svg", "png"].include?(image_format)
        raise INVALID_IMAGE_FORMAT_ERROR
      end
    end

    def write_lily_code_file(lily)
      open(lily.code_filename, 'w') do |code_file|
        code_file.puts(lily.code)
      end
    end

    def generate_lily_image(lily)
      system("lilypond", lilypond_output_format_option, lily.code_filename)
      system("mv", lily.image_filename, "lily_images/")
      has_audio = File.exists?(lily.midi_filename)
      if has_audio
        system("fluidsynth", "-ni", "/opt/local/share/sounds/sf2/FluidR3_GM.sf2", lily.midi_filename,
               "-F", lily.wav_filename, "-r", "44100")
        system("lame", "-V2", "-m", "m", lily.wav_filename, lily.mp3_filename)
        system("rm", lily.midi_filename)
        system("rm", lily.wav_filename)
        system("mv", lily.mp3_filename, "lily_images/")
      end
      system("rm", lily.code_filename)
      return has_audio
    end

    def add_lily_image_to_site(lily, has_audio)
      site_manager.add_image(static_file_builder, lily.image_filename)
      site_manager.add_image(static_file_builder, lily.mp3_filename) if has_audio
    end

    def replace_snippet_with_image_link(lily, has_audio)
      replacement = lily.image_link
      replacement += lily.mp3_link if has_audio
      content.gsub!(lily.snippet, replacement)
    end

    def lilies
      lily_snippets.map do |snippet|
        Lily.new(naming_policy.generate_name, image_format, snippet, site_manager.site)
      end
    end

    def lily_snippets
      content.scan(/```lilypond.+?```\n/m)
    end

    def lilypond_output_format_option
      image_format == "png" ? "--png" : "-dbackend=svg"
    end
  end
end
