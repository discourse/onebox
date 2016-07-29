module Onebox
  module Engine
    class OsuBeatmapOnebox
      include Engine
      include LayoutSupport
      include HTML

      matches_regexp(/^(https?:\/\/)?(osu\.ppy\.sh\/)([bs]\/)([\d]*\/?)(&m=[\d])?$/)

      private

      def data
        result = {
          link: link,
          title: raw.css("title").text,
          image: raw.css("img.bmt").first['src'],
          description: raw.css("div.posttext").text
        }
      end
    end
  end
end
