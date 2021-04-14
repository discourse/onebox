# frozen_string_literal: true

module Onebox
  module Mixins
    module GithubBody
      def self.included(klass)
        klass.include(Onebox::Engine)
        klass.include(InstanceMethods)
      end

      module InstanceMethods
        GITHUB_COMMENT_REGEX = /(<!--.*?-->\r\n)/
        MAX_BODY_LENGTH = 80
        def compute_body(body)
          body = body.dup
          excerpt = nil

          body = (body || '').gsub(GITHUB_COMMENT_REGEX, '')
          body = body.length > 0 ? body : nil
          if body && body.length > MAX_BODY_LENGTH
            excerpt = body[MAX_BODY_LENGTH..body.length].rstrip
            body = body[0..MAX_BODY_LENGTH - 1]
          end

          [body, excerpt]
        end
      end
    end
  end
end
