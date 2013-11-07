require 'onebox/engine'
require 'onebox/engine/open_graph'
require 'onebox/layout_support'

module Onebox
  module Engine
    class Revision3Onebox
      include Engine
      include LayoutSupport
      include OpenGraph

      matches do
        http
        domain("revision3")
        tld("com")
      end

      private

      def data
        {
          link: link,
          domain: "http://revision3.com",
          badge: "r",
          title: raw.title,
          image: raw.images.first,
          description: raw.description,
          video: raw.metadata[:video].first[:_value]
        }
      end
    end
  end
end

