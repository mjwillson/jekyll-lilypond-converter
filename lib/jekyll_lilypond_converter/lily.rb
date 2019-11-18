module JekyllLilyPondConverter
  class Lily
    attr_reader :snippet

    def initialize(id, extension, snippet, site)
      @id = id
      @extension = extension
      @snippet = snippet
      @site = site
    end

    def code_filename
      "#{id}.ly"
    end

    def image_filename
      "#{id}.#{extension}"
    end

    def midi_filename
      "#{id}.midi"
    end

    def wav_filename
      "#{id}.wav"
    end

    def mp3_filename
      "#{id}.mp3"
    end

    def image_link
      "![](#{baseurl}/lily_images/#{image_filename})\n"
    end

    def mp3_link
      <<END
<div>
  <audio controls="controls">
    <source type="audio/mp3" src="#{baseurl}/lily_images/#{mp3_filename}"></source>
    <p>Your browser does not support the audio element.</p>
  </audio>
</div>
END
    end

    def code
      strip_delimiters(snippet)
    end

    private
    attr_reader :id, :extension

    def strip_delimiters(snippet)
      snippet.gsub(/```lilypond\n/, "").gsub(/```\n/, "")
    end

    def baseurl
      @site.config["baseurl"].to_s.chomp("/")
    end
  end
end
