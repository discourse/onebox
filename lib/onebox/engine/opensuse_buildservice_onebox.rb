module Onebox
  module Engine
    class OpensuseBuildServiceOnebox
      include Engine
      include LayoutSupport
      include HTML
      always_https

      matches_regexp(%r{^(https?://)?build\.opensuse\.org/\w+/show/(.)+$})

      private

      def data
        {
          image: avatar,
          link: link,
          title: user? ? raw.css('#home-realname').text : raw.css('div.alpha h3')[0].text,
          description: user? ? raw.css('#home-username').text : raw.css('#description-text').text,
          request: request,
          packages: package
        }
      end

      def avatar
        if request?
          author_avatar
        elsif user?
          raw.css('.home-avatar').attr('src')
        end
      end

      def user?
        link =~ %r{/user/}
      end

      def request?
        link =~ %r{/request/}
      end

      def package?
        link =~ %r{/package/}
      end

      def author_link
        'https://build.opensuse.org' + raw.css('.clean_list li a').first['href']
      end

      def author_avatar
        author_html = Nokogiri::HTML(open(author_link))
        author_html.css('.home-avatar').attr('src')
      end

      def fuzzy_time
        raw.css('.clean_list li span.fuzzy-time')[0].text
      end

      def request
        return unless request?

        [{
          "author_link": author_link,
          "author_name": File.basename(author_link),
          "fuzzy_time": fuzzy_time
        }]
      end

      def package
        return unless package?

        paths = URI(link).path.split('/')
        [{ "project": paths[-2], "package": paths[-1] }]
      end
    end
  end
end
