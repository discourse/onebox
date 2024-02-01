# frozen_string_literal: true

module Onebox
  module Engine
    module HTML
      private

      # Overwrite for any custom headers
      def http_params
        {}
      end

      def raw
        @raw ||= Onebox::Helpers.fetch_html_doc(url, http_params, body_cacher)
      end

      def body_cacher
        self.options&.[](:body_cacher)
      end

      def html?
        raw.respond_to(:css)
      end
    end
  end
end
