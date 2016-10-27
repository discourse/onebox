require 'htmlentities'

module Onebox
  module Engine
    class WhitelistedGenericOnebox
      include Engine
      include StandardEmbed
      include LayoutSupport

      def self.whitelist=(list)
        @whitelist = list
      end

      def self.whitelist
        @whitelist ||= default_whitelist.dup
      end

      def self.default_whitelist
        %w(23hq.com
          500px.com
          8tracks.com
          abc.net.au
          about.com
          answers.com
          arstechnica.com
          ask.com
          battle.net
          bbc.co.uk
          bbs.boingboing.net
          bestbuy.ca
          bestbuy.com
          blip.tv
          bloomberg.com
          businessinsider.com
          clikthrough.com
          cnet.com
          cnn.com
          collegehumor.com
          consider.it
          coursera.org
          codepen.io
          cracked.com
          dailymail.co.uk
          dailymotion.com
          deadline.com
          dell.com
          deviantart.com
          digg.com
          dotsub.com
          ebay.ca
          ebay.co.uk
          ebay.com
          ehow.com
          espn.go.com
          etsy.com
          findery.com
          flickr.com
          folksy.com
          forbes.com
          foxnews.com
          funnyordie.com
          gfycat.com
          groupon.com
          howtogeek.com
          huffingtonpost.com
          huffingtonpost.ca
          hulu.com
          ign.com
          ikea.com
          imdb.com
          indiatimes.com
          instagr.am
          instagram.com
          itunes.apple.com
          khanacademy.org
          kickstarter.com
          kinomap.com
          liveleak.com
          livestream.com
          lessonplanet.com
          mashable.com
          medium.com
          meetup.com
          mixcloud.com
          mlb.com
          myshopify.com
          myspace.com
          nba.com
          nytimes.com
          npr.org
          photobucket.com
          pinterest.com
          reference.com
          revision3.com
          rottentomatoes.com
          samsung.com
          screenr.com
          scribd.com
          slideshare.net
          sourceforge.net
          speakerdeck.com
          spotify.com
          squidoo.com
          techcrunch.com
          ted.com
          thefreedictionary.com
          theglobeandmail.com
          thenextweb.com
          theonion.com
          thestar.com
          thesun.co.uk
          thinkgeek.com
          tmz.com
          torontosun.com
          tumblr.com
          twitch.tv
          twitpic.com
          usatoday.com
          viddler.com
          videojug.com
          vimeo.com
          vine.co
          walmart.com
          washingtonpost.com
          wikia.com
          wikihow.com
          wired.com
          wistia.com
          wi.st
          wonderhowto.com
          wsj.com
          zappos.com
          zillow.com
          change.org)
      end

      # Often using the `html` attribute is not what we want, like for some blogs that
      # include the entire page HTML. However for some providers like Flickr it allows us
      # to return gifv and galleries.
      def self.default_html_providers
        ['Flickr', 'Meetup']
      end

      def self.html_providers
        @html_providers ||= default_html_providers.dup
      end

      def self.html_providers=(new_provs)
        @html_providers = new_provs
      end

      # A re-written URL coverts http:// -> https://
      def self.rewrites
        @rewrites ||= https_hosts.dup
      end

      def self.rewrites=(new_list)
        @rewrites = new_list
      end

      def self.https_hosts
        %w(slideshare.net dailymotion.com livestream.com)
      end

      def self.host_matches(uri, list)
        !!list.find {|h| %r((^|\.)#{Regexp.escape(h)}$).match(uri.host) }
      end

      def self.probable_discourse(uri)
        !!(uri.path =~ /\/t\/[^\/]+\/\d+(\/\d+)?(\?.*)?$/)
      end

      def self.probable_wordpress(uri)
        !!(uri.path =~ /\d{4}\/\d{2}\//)
      end

      def self.===(other)
        if other.kind_of?(URI)
          return WhitelistedGenericOnebox.host_matches(other, WhitelistedGenericOnebox.whitelist) ||
                 WhitelistedGenericOnebox.probable_wordpress(other) ||
                 WhitelistedGenericOnebox.probable_discourse(other)
        else
          super
        end
      end

      # Generates the HTML for the embedded content
      def photo_type?
        ( (data[:type] =~ /photo/ || data[:type] =~ /image/) && data[:type] !~ /photostream/ )
      end

      def article_type?
        data[:type] == "article"
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
        return add_thumbnail_class(data[:html]) if html_type?
        return layout.to_html if article_type?
        return html_for_video(data[:video]) if data[:video]
        return image_html if photo_type?
        return nil if data[:title].nil? || data[:title].empty?

        layout.to_html
      end

      def to_html
        rewrite_https(generic_html)
      end

      def placeholder_html
        result = nil
        return to_html if article_type?
        result = image_html if (data[:html] && data[:html] =~ /iframe/) || data[:video] || photo_type?
        result || to_html
      end

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
      end

      private

      def image_html
        return @image_html if @image_html

        return @image_html = "<img src=\"#{data[:url]}\">" if data[:url]

        if data[:thumbnail_url]
          @image_html = "<img src=\"#{data[:thumbnail_url]}\""
          @image_html << " width=\"#{data[:thumbnail_width]}\"" if data[:thumbnail_width]
          @image_html << " height=\"#{data[:thumbnail_height]}\"" if data[:thumbnail_height]
          @image_html << ">"
        end

        @image_html
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
          # opengraph support multiple elements (videos, images ,etc).
          # We attempt to find a video element with the type of video/mp4
          # and generate a native <video> element for it.

          if (@raw.metadata && @raw.metadata[:"video:type"])
            video_type =  @raw.metadata[:"video:type"]
            if video_type.include? "video/mp4"            # find if there is a video with type
              if video_type.size > 1                      # if more then one video item based on provided video_type
                ind = video_type.find_index("video/mp4")  # get the first video index with type video/mp4
                video_url  = @raw.metadata[:video][ind]   # update video_url
              end

              attr = append_attribute(:width, attr, video)
              attr = append_attribute(:height, attr, video)

              site_name_and_title  =  ( ("<span style='color:#fff;background:#9B9B9B;border-radius:3px;padding:3px;margin-right: 5px;'>" + CGI::escapeHTML(@raw.metadata[:site_name][0].to_s) + '</span> ') + CGI::escapeHTML((@raw.title || @raw.description).to_s) )
              orig_url = @raw.url
              html_v2 = %Q(
                <div style='position:relative;padding-top:29px;'>
                <span style='position: absolute;top:0px;z-index:2;color:#000;white-space:nowrap;text-overflow:ellipsis;word-wrap: break-word;overflow: hidden;display: inline-block;padding: 3px;border-radius: 4px;max-width: 100%;'><a href='#{orig_url}' target='_blank'>#{site_name_and_title}</a></span>
                <video style='max-width:100%' #{attr} title="#{data[:title]}" controls="" ><source src="#{video_url}"></video>
                </div>
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

      def append_attribute(attribute, html, video)
        if video.is_a?(Hash) && video[attribute] && video[attribute].first
          val = video[attribute].first[:_value]
          html << " #{attribute.to_s}=\"#{val}\""
        end
      end

      def add_thumbnail_class(data)
        fragment = Nokogiri::HTML::fragment(data)
        if fragment
          fragment.search('img').each do |img|
            img['class'] = "thumbnail"
          end
        end

        return fragment.to_html
      end
    end
  end
end
