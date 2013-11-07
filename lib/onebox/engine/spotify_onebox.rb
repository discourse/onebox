require 'onebox/engine'
require 'onebox/engine/open_graph'
require 'onebox/layout_support'

module Onebox
  module Engine
    class SpotifyOnebox
      include Engine
      include LayoutSupport
      include OpenGraph

      matches do
        http
        with("open.")
        domain("spotify")
        tld("com")
      end

      private

      def data
        {
          link: link,
          domain: "http://open.spotify.com",
          badge: "s",
          title: raw.title,
          image: raw.images.first,
          description: raw.description
        }
      end
    end
  end
end

