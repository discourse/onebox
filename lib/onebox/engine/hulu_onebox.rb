module Onebox
  module Engine
    class HuluOnebox
      include Engine
      include OpenGraph

      matches do
        #/^https?\:\/\/www\.hulu\.com\/watch\/.*$/
        find "hulu.com"
      end

      private

      def extracted_data
        {
          url: @url,
          title: @body.title,
          image: @body.images[0],
          description: @body.description
        }
      end
    end
  end
end
