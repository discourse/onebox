module Onebox
  module Engine
    class GithubBlobOnebox
      include Engine
      include LayoutSupport

      matches_regexp(/^(https?:\/\/)(www.facebook.com\/)(.)+\/?$/)

      def get_app_fb_graph_api
        # get FB app access token
        @fb_app_graph_api ||= Koala::Facebook::API.new([
          ENV['FACEBOOK_APP_ID'],
          ENV['FACEBOOK_APP_SECRET']].join('|'))
      end

      def parse_fb_photo(photo_id)
        # 解析 FB 照片內容
        fb_graph_api = get_app_fb_graph_api
        photo_content = fb_graph_api.get_object(photo_id)
        result = {
          link: link,
          image?: true,
          comments: []
        }
        result[:image] = photo_content["source"]
        result[:title] = photo_content["name"][0..20]
        result[:content] = photo_content["name"].gsub("\n", "<br />")
        result[:source_url] = photo_content["link"]
        result[:date] = Time.parse(photo_content["created_time"])
        img_width = 0
        photo_content["images"].each do | img |
          if img["width"] > img_width
            img_width = img["width"]
            result[:image] = img["source"]
          end
        end
        comment_id = photo_id + '/comments'
        comments = fb_graph_api.get_object(comment_id, {limit: 100000})
        comments.each do |c|
          comment_author = c["from"]["name"]
          comment = {}
          comment[:author] = comment_author
          comment[:content] = c["message"].gsub("\n", "<br />")
          result[:comments] << comment
        end
        return result
      end

      def parse_fb_post(post_id)
        # 解析 FB 貼文內容
        fb_graph_api = get_app_fb_graph_api
        post_content = fb_graph_api.get_object(post_id)
        result = {
          link: link,
          image?: false,
          comments: []
        }
        if post_content["name"]
          result[:title] = post_content["name"]
        else
          result[:title] = post_content["message"][0..20]
        end
        result[:content] = post_content["message"].gsub("\n", "<br />")
        result[:image] = post_content["picture"] if post_content["picture"]
        result[:image?] = true if post_content["picture"]
        result[:link] = post_content["link"] if post_content["link"]
        result[:date] = Time.parse(post_content["created_time"])
        comment_id = post_id + '/comments'
        comments = fb_graph_api.get_object(comment_id, {limit: 100000})
        comments.each do |c|
          comment_author = c["from"]["name"]
          comment = {}
          comment[:author] = comment_author
          comment[:content] = c["message"].gsub("\n", "<br />")
          result[:comments] << comment
        end
        return result
      end

      def parse_fb_link(link_id)
        # 解析 FB 分享連結內容
        fb_graph_api = get_app_fb_graph_api
        link_content = fb_graph_api.get_object(link_id)
        result = {
          link: link,
          image?: true,
          comments: []
        }
        result[:title] = link_content["message"]["name"]
        result[:content] = link_content["message"].gsub("\n", "<br />")
        result[:link] = link_content["link"]
        result[:image] = link_content["picture"]
        result[:date] = Time.parse(link_content["created_time"])

        comment_id = link_id + '/comments'
        comments = fb_graph_api.get_object(comment_id, {limit: 100000})
        comments.each do |c|
          comment_author = c["from"]["name"]
          comment = {}
          comment[:author] = comment_author
          comment[:content] = c["message"].gsub("\n", "<br />")
          result[:comments] << comment
        end
        return result
      end

      def data
        source_uri = URI.parse(link)
        path_elements = source_uri.path.split('/')
        if path_elements[1] == 'photo.php'
          photo_id = CGI::parse(source_uri.query)['fbid'].first
          parse_fb_photo(photo_id)
        elsif path_elements[1] == 'permalink.php'
          link_id = CGI::parse(source_uri.query)['story_fbid'].first
          result = parse_fb_link(link_id)
        elsif path_elements[2] == 'photos'
          photo_id = path_elements.last
          parse_fb_photo(photo_id)
        elsif path_elements[2] == 'posts'
          fb_user_name = path_elements[1]
          fb2_graph_api = Koala::Facebook::API.new
          fb_user_id = fb2_graph_api.get_object(fb_user_name)['id']
          post_id = [fb_user_id, path_elements.last].join('_')
          parse_fb_post(post_id)
        else
          return false
        end

      end

    end
  end
end