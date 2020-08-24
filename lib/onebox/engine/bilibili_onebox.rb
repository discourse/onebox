# frozen_string_literal: true

module Onebox
  module Engine
    class BiliBiliOnebox
      include Engine
      matches_regexp(/^https?:\/\/(www\.)?(bilibili.com)\/(video\/)(av|bv)(\w+)/i)
      def to_html
        placeholder_html()
      end

      def placeholder_html
        "<iframe src=\"https://player.bilibili.com/player.html?aid=#{id()}&amp;page=1&amp;as_wide=1\" frameborder=\"0\" width=\"640\" height=\"430\" allowfullscreen=\"true\" seamless=\"seamless\" sandbox=\"allow-same-origin allow-scripts allow-forms allow-popups allow-popups-to-escape-sandbox allow-presentation\"></iframe>"
      end

      private
      # decode copied from  https://github.com/ShiSheng233/bili_BV/blob/master/biliBV/__init__.py
      @@key = 'fZodR9XQDSUm21yCkr6zBqiveYah8bt4xsWpHnJE7jL5VG3guMTKNPAwcF'
      @@dic = {}

      for a in 0..57
        @@dic[@@key[a]] = a
      end

      @@s = [11, 10, 3, 8, 4, 6]
      @@xor = 177451812
      @@add = 8728348608

      def decode(in_)
        r = 0
        for a in 0..5
          @@r = @@dic[in_[@@s[a]]] * 58**a + @@r
        end
      (@@r - @@add) ^ @@xor
      end

      def id
        match = @url.match(/(bv|av)(.*)/i)
        if match[1] == "BV" || match[1] == "bv"
          decode(match[1] + match[2])
        else
          match[2]
        end
      end
    end
  end
end
