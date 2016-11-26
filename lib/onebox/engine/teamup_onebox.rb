module Onebox
  module Engine
    class TeamupOnebox
      include Engine
      include StandardEmbed

      matches_regexp /^(https?:)?\/\/teamup\.com\/\w+$/
      always_https

      def to_html
        <<-HTML
          <iframe src="//teamup.com#{uri.path}"
                  width="800"
                  height="700"
                  scrolling="no"
                  frameborder="0">
          </iframe>
        HTML
      end

      # taken from Google Calendar Engine to present a white placeholder
      def placeholder_html
        <<HTML
<div placeholder><div style='display:table-cell;vertical-align:middle;width:800px;height:700px'>
<div style='text-align:center;'>
<p>Teamup Calendar</p>
</div></div></div>
HTML
      end

    end
  end
end
