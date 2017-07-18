module Onebox
  module Engine
    class ImdbOnebox
      include Engine
      include StandardEmbed
      include LayoutSupport

      matches_regexp(/^https?:\/\/(?:www\.)?(?:m\.)?(?:imdb\.com)\//)

      def url
        url = @url
        # IMDb mobile pages has blank description tag, resulting in broken onebox. Work around that.
        url = @url.gsub("//m.", "//www.") if @url =~ /^https?:\/\/m.imdb.com\//
        url
      end

      private

        def data
          og = get_opengraph
          {
            link: og[:url],
            title: og[:title],
            description: og[:description],
            image: og[:image]
          }
        end

    end
  end
end
