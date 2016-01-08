module Onebox
  module Engine
    class KalturaOnebox
      include Engine
      include StandardEmbed
      matches_regexp(/^https?:\/\/(?:www\.)?(?:kaltura\.com)\/.+$/)
      def data
        if raw.is_a?(Hash)
          raw[:link] ||= link
          raw[:title] = HTMLEntities.new.decode(raw[:title])
          return raw
        end

        data_hash = { link: link, title: HTMLEntities.new.decode(raw.title), description: raw.description }
        data_hash[:image] = raw.images.first if raw.images && raw.images.first
        data_hash[:type] = raw.type if raw.type

        if raw.metadata && raw.metadata[:"video:secure_url"] && raw.metadata[:"video:secure_url"].first
          data_hash[:video] = raw.metadata[:"video:secure_url"].first
        elsif raw.metadata && raw.metadata[:video] && raw.metadata[:video].first
          data_hash[:video] = raw.metadata[:video].first
        end

        if raw.metadata && raw.metadata[:"twitter:label1"] && raw.metadata[:"twitter:data1"]
          data_hash[:twitter_label1] = raw.metadata[:"twitter:label1"].first
          data_hash[:twitter_data1] = raw.metadata[:"twitter:data1"].first
        end

        if raw.metadata && raw.metadata[:"twitter:label2"] && raw.metadata[:"twitter:data2"]
          data_hash[:twitter_label2] = raw.metadata[:"twitter:label2"].first
          data_hash[:twitter_data2] = raw.metadata[:"twitter:data2"].first
        end

        data_hash
	#print data_hash
      end
      def html_for_video(video)
        if video.is_a?(String)
          video_url = video
        elsif video.is_a?(Hash)
          video_url = video[:_value]
        else
          return
        end


        if video_url
          if (@raw.metadata && @raw.metadata[:"video:type"])
            video_type =  @raw.metadata[:"video:type"]
            if video_type.include? "video/mp4"            # find if there is a video with type
              if video_type.size > 1                      # if more then one video item based on provided video_type
                ind = video_type.find_index("video/mp4")  # get the first video index with type video/mp4
                video_url  = @raw.metadata[:video][ind]   # update video_url
              end

              attr = append_attribute(:width, attr, video)
              attr = append_attribute(:height, attr, video)
              orig_url = @raw.url
	      match = orig_url.match(/.*\/partner_id\/([0-9]+)\/uiconf_id\/([0-9]+)\/entry_id\/([0-9a-z_]+)/)
	      partner_id=match[1]
	      uiconf_id=match[2]
	      entry_id=match[3]
	      match = video_url.match(/(^https?:\/\/.*\.kaltura\.com)\/.+$/)
	      cdn_host=match[1]


              html_v2 = %Q(

<div style="width: 60%;display: inline-block;position: relative;">
<!--  inner pusher div defines aspect ratio: in this case 16:9 ~ 56.25% -->
<div id="dummy" style="margin-top: 56.25%;"></div>
<!--  the player embed target, set to take up available absolute space   -->
<div id="kaltura_player_#{entry_id}_#{uiconf_id}" style="position:absolute;top:0;left:0;left: 0;right: 0;bottom:0;border:solid thin black;">
</div>
</div>
<script src="#{cdn_host}/p/#{partner_id}/sp/#{partner_id}00/embedIframeJs/uiconf_id/#{uiconf_id}/partner_id/#{partner_id}"></script>
<script>
kWidget.embed({
"targetId": "kaltura_player_#{entry_id}_#{uiconf_id}",
"wid": "_#{partner_id}",
"uiconf_id": #{uiconf_id},
"flashvars": {
"streamerType": "auto",
},
"cache_st": 1450868353,
"entry_id": "#{entry_id}"
});
</script>
                )
              html = html_v2

            else

              html = "<iframe src=\"#{video_url}\" frameborder=\"0\" title=\"#{data[:title]}\""
              append_attribute(:width, html, video)
              append_attribute(:height, html, video)

              html << "></iframe>"
            end

          end
          return html
        end
      end
      def rewrite_https(html)
        return html unless html
        uri = URI(@url)
        if WhitelistedGenericOnebox.host_matches(uri, WhitelistedGenericOnebox.rewrites)
          html.gsub!(/http:\/\//, 'https://')
        end
        html
      end

      def html_type?
        return data &&
               data[:html] &&
               (
                 (data[:html] =~ /iframe/) ||
                 WhitelistedGenericOnebox.html_providers.include?(data[:provider_name])
               )
      end
      def generic_html
        return data[:html] if html_type?
        return nil unless data[:title]
      end

      def to_html
	return html_for_video(data[:video]) if data[:video]
	return generic_html
      end
      def append_attribute(attribute, html, video)
        if video.is_a?(Hash) && video[attribute] && video[attribute].first
          val = video[attribute].first[:_value]
          html << " #{attribute.to_s}=\"#{val}\""
        end
      end


    end
  end
end
