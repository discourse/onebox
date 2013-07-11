module Discourse
  module Oneboxer
    class GithubBlobOnebox < HandlebarsOnebox

      matcher /^https?:\/\/(?:www\.)?github\.com\/[^\/]+\/[^\/]+\/blob\/.*/
      favicon 'github.png'

      def translate_url
        m = @url.match(/github\.com\/(?<user>[^\/]+)\/(?<repo>[^\/]+)\/blob\/(?<sha1>[^\/]+)\/(?<file>[^#]+)(#(L(?<from>[^-]*)(-L(?<to>.*))?))?/mi)
        if m
          @from = (m[:from] || -1).to_i
          @to = (m[:to] || -1).to_i
          @file = m[:file]
          return "https://raw.github.com/#{m[:user]}/#{m[:repo]}/#{m[:sha1]}/#{m[:file]}"
        end
        nil
      end

      def parse(data)

        if @from > 0
          if @to < 0
            @from = @from - 10
            @to = @from + 20
          end
          if @to > @from
            data = data.split("\n")[@from..@to].join("\n")
          end
        end

        extension = @file.split(".")[-1]
        @lang = case extension
                  when "rb" then "ruby"
                  when "js" then "javascript"
                  else extension
               end

        truncated = false
        if data.length > SiteSetting.onebox_max_chars
          data = data[0..SiteSetting.onebox_max_chars-1]
          truncated = true
        end

        {content: data, truncated: truncated}
      end

    end
  end
end