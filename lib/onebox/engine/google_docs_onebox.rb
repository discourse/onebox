# frozen_string_literal: true

module Onebox
  module Engine
    class GoogleDocsOnebox
      include Engine
      include StandardEmbed
      include LayoutSupport

      def self.supported_endpoints
        %w(spreadsheets document forms presentation)
      end

      def self.short_types
        @shorttypes ||= {
          spreadsheets: :sheets,
          document: :docs,
          presentation: :slides,
          forms: :forms,
        }
      end

      matches_regexp /^(https?:)?\/\/(docs\.google\.com)\/(?<endpoint>(#{supported_endpoints.join('|')}))\/d\/((?<key>[\w-]*)).+$/
      always_https

      protected

      def data
        og_data = get_opengraph

        title = og_data.title || "Google #{shorttype.to_s.capitalize}"
        description = og_data.description.present? ? Onebox::Helpers.truncate(og_data.description, 250) : "This #{shorttype.to_s.chop.capitalize} is private"

        result = { link: link,
                   title: title,
                   description: description,
                   type: shorttype
                 }
        result
      end

      def doc_type
        @doc_type ||= match[:endpoint].to_sym
      end

      def shorttype
        GoogleDocsOnebox.short_types[doc_type]
      end

      def match
        @match ||= @url.match(@@matcher)
      end
    end
  end
end
