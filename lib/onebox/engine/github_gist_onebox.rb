module Onebox
  module Engine
    class GithubGistOnebox
      include Engine

      matches do
        http
        with("gist.")
        domain("github")
        tld("com")
      end

      def url
        "https://api.github.com/gists/#{match[:sha]}"
      end

      def to_html
        '<script src="//gist.github.com/#{match[:sha]}.js"></script>'
      end

      private

      def data
        { sha: match[:sha], title: match[:sha], link: @url }
      end

      def match
        @match ||= @url.match(%r{gist\.github\.com/([^/]+/)?(?<sha>[0-9a-f]+)})
      end

    end
  end
end
