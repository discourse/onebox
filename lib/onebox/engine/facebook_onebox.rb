module Onebox
  module Engine
    class FacebookOnebox
      include Engine
      include LayoutSupport

      if ENV['FACEBOOK_APP_ID'] and ENV['FACEBOOK_APP_SECRET']
        matches_regexp(/^(https?:\/\/)(www.facebook.com\/)(.)+\/?$/)
      else
        # make it match nothing
        matches_regexp(/[^\s\S]/)
      end

      private

      def get_app_fb_graph_api
        # get FB app access token
        @fb_app_graph_api ||= Koala::Facebook::API.new([
          ENV['FACEBOOK_APP_ID'],
          ENV['FACEBOOK_APP_SECRET']].join('|'))
      end

      def parse_fb_photo(photo_id)
        # Parse fb photo
        fb_graph_api = get_app_fb_graph_api
        photo_content = fb_graph_api.get_object(photo_id)
        result = {
          link: link,
          has_image?: true,
          comments: []
        }
        result[:image] = photo_content["source"]
        result[:title] = photo_content["name"].strip.split("\n")[0][0..20]
        result[:description] = photo_content["name"].gsub("\n", "<br />")
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
        # Parse fb post
        fb_graph_api = get_app_fb_graph_api
        post_content = fb_graph_api.get_object(post_id)
        result = {
          link: link,
          has_image?: false,
          comments: []
        }
        if post_content["message"]
          if post_content["name"]
            result[:title] = post_content["name"].to_s.strip
          else
            result[:title] = post_content["message"].to_s.strip.split("\n")[0][0..20]
          end
          result[:description] = post_content["message"].to_s.gsub("\n", "<br />")
        else
          result[:title] = post_content["name"].to_s.strip.split("\n")[0][0..20]
          result[:description] = post_content["description"].to_s.gsub("\n", "<br />")
        end
        result[:image] = post_content["picture"] if post_content["picture"]
        result[:has_image?] = true if post_content["picture"]
        result[:source_url] = post_content["link"] if post_content["link"]
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
        # Parse fb share link
        fb_graph_api = get_app_fb_graph_api
        link_content = fb_graph_api.get_object(link_id)
        puts link_content
        result = {
          link: link,
          has_image?: true,
          comments: []
        }
        result[:title] = link_content["message"].to_s.strip.split("\n")[0][0..20]
        result[:description] = link_content["message"].gsub("\n", "<br />")
        result[:source_url] = link_content["link"] if link_content["link"]
        result[:image] = post_content["picture"] if post_content["picture"]
        result[:has_image?] = true if post_content["picture"]
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
          return parse_fb_photo(photo_id)
        elsif path_elements[1] == 'permalink.php'
          link_id = CGI::parse(source_uri.query)['story_fbid'].first
          return parse_fb_link(link_id)
        elsif path_elements[2] == 'photos'
          photo_id = path_elements.last
          return parse_fb_photo(photo_id)
        elsif path_elements[2] == 'posts'
          fb_user_name = path_elements[1]
          fb2_graph_api = Koala::Facebook::API.new
          fb_user_id = fb2_graph_api.get_object(fb_user_name)['id']
          post_id = [fb_user_id, path_elements.last].join('_')
          return parse_fb_post(post_id)
        else
          raise Net::HTTPError
        end
      end
    end
  end
end