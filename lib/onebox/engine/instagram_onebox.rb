# frozen_string_literal: true

module Onebox
  module Engine
    class InstagramOnebox
      include Engine
      include StandardEmbed
      include LayoutSupport

      matches_regexp(/^https?:\/\/(?:www\.)?(?:instagram\.com|instagr\.am)\/?(?:.*)\/p\/[a-zA-Z\d_-]+/)
      always_https

      def clean_url
        url.scan(/^https?:\/\/(?:www\.)?(?:instagram\.com|instagr\.am)\/?(?:.*)\/p\/[a-zA-Z\d_-]+/).flatten.first
      end

      def data
        oembed = get_oembed
        permalink = clean_url.gsub("/#{oembed.author_name}/", "/")

        { link: permalink,
          title: "@#{oembed.author_name}",
          image: oembed.thumbnail_url,
          description: oembed.title,
        }

      end

      protected

      def access_token
        options[:facebook_app_access_token]
      end

      def get_oembed_url
        if access_token && access_token != ''
          oembed_url = "https://graph.facebook.com/v9.0/instagram_oembed?url=#{clean_url}&access_token=#{access_token}"
        else
          # The following is officially deprecated by Instagram, but works in some limited circumstances.
          oembed_url = "https://api.instagram.com/oembed/?url=#{clean_url}"
        end
      end
    end
  end
end
