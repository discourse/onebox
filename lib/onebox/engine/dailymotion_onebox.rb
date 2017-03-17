module Onebox
  module Engine
    class DailymotionOnebox
      include Engine
      include StandardEmbed

      matches_regexp(/^https?:\/\/www\.dailymotion\.com\/video\//)
      always_https

      def to_html
        og = get_opengraph
        escaped_src = ::Onebox::Helpers.normalize_url_for_output(og[:video_secure_url])
        escaped_src = escaped_src.gsub("autoplay=1", "autoplay=0")
        "<iframe src='#{escaped_src}' width='#{og[:video_width]}' height='#{og[:video_height]}' #{Helpers.title_attr(og)} frameborder=0></iframe>"
      end

    end
  end
end
