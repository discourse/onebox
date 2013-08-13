module Onebox
  class Preview
    class Qik
      TEMPLATE = File.read(File.join("templates", "qik.handlebars"))

      def initialize(document, link)
        @url = link
        @body = document
        @data = extracted_data
        @view = Mustache.render(TEMPLATE, @data)
      end

      def to_html
        @view
      end

      private

      def extracted_data
        {
          url: @url,
          title: @body.css(".info h2").inner_text,
          image: @body.css(".userphoto").first["src"],
          # description: @body.css("html body #postBodyPS").inner_text,
          # price: @body.css("html body .priceLarge").inner_text
        }
      end
    end
  end
end
