module Onebox
  module Engine
    class WikipediaOnebox
      include Engine
      include HTML

      matches do
        # /^https?:\/\/.*wikipedia\.(com|org)\/.*$/
        find "wikipedia.com"
      end

      private

      def data
        {
          url: @url,
          name: raw.css("html body h1").inner_text,
          image: raw.css(".infobox .image img").first["src"],
          description: raw.css("html body p").inner_text
        }
      end
    end
  end
end
