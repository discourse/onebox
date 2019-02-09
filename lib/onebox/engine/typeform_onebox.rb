module Onebox
  module Engine
    class TypeformOnebox
      include Engine
      include StandardEmbed

      matches_regexp(/^https?:\/\/[a-z0-9]+\.typeform\.com\/to\/[a-zA-Z0-9]+/)
      always_https

      def placeholder_html
        og = get_opengraph
        escaped_src = ::Onebox::Helpers.normalize_url_for_output(og[:image])
        "<img src='#{escaped_src}' #{Helpers.title_attr(og)}>"
      end

      def to_html
        og = get_opengraph
        escaped_src = ::Onebox::Helpers.normalize_url_for_output(og[:url])
        query_params = CGI::parse(URI::parse(escaped_src).query || '')
        escaped_src = append_embed_param(escaped_src, query_params)

        <<-HTML
          <iframe src="#{escaped_src}"
                  width="100%"
                  height="600px"
                  scrolling="no"
                  frameborder="0">
          </iframe>
        HTML
      end

      private

      def append_embed_param(src, query_params)
        return src if query_params.has_key?('typeform-embed')

        src.tap do |url_to_embed|
          url_to_embed << '?' if query_params.empty?
          url_to_embed << 'typeform-embed=embed-widget'
        end
      end
    end
  end
end
