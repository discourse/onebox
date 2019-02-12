module Onebox
  module Engine
    class GiphyOnebox
      include Engine
      include StandardEmbed

      matches_regexp(/^https?:\/\/(giphy\.com\/gifs|gph\.is)\//)
      always_https

      def to_html
        oembed = get_oembed
        escaped_url = ::Onebox::Helpers.normalize_url_for_output(oembed[:url])

        <<-HTML
          <a href="#{escaped_url}" target="_blank" class="onebox">
            <img src="#{escaped_url}" width="#{oembed[:width]}" height="#{oembed[:height]}" #{Helpers.title_attr(oembed)}>
          </a>
        HTML
      end

    end
  end
end
