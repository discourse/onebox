module Onebox
  module Engine
    class GoogleDriveOnebox
      include Engine
      include StandardEmbed

      matches_regexp(/^https?:\/\/drive\.google\.com\/file\/d\/.*\/view/)
      always_https

      def to_html
        og = get_opengraph
        if !Onebox::Helpers::blank?(og[:image])
          escaped_img_src = ::Onebox::Helpers.normalize_url_for_output(og[:image])
          escaped_url_src = ::Onebox::Helpers.normalize_url_for_output(og[:url])

          return <<-HTML
<a href="#{escaped_url_src}" target="_blank">
  <img alt='GoogleDrive' src="#{escaped_img_src}" width="#{og[:image_width]}" height="#{og[:image_height]}" />
</a>
          HTML
        end
        nil
      end
    end
  end
end
