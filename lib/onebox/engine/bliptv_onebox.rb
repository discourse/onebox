require 'onebox/engine'
require 'onebox/engine/open_graph'
require 'onebox/layout_support'

module Onebox
  module Engine
    class BliptvOnebox
      include Engine
      include LayoutSupport
      include OpenGraph

      matches do
        http
        maybe("www.")
        domain("blip")
        has(".tv").maybe("/")
      end

      private

      def data
        {
          link: link,
          domain: "http://blip.tv",
          badge: "b",
          title: raw.title,
          image: raw.images.first,
          description: raw.description,
          video: raw.metadata[:video].first[:_value]
        }
      end
    end
  end
end

