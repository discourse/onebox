module Onebox
  class OpenGraph

    attr_reader :doc, :og

    def initialize(doc)
      @doc = doc
      @og = extract
    end

    def title
      get(:title, 80)
    end

    def title_attr
      !title.nil? ? "title='#{title}'" : ""
    end

    def method_missing(attr, *args, &block)
      value = get(attr, *args)

      return nil if Onebox::Helpers::blank?(value)

      method_name = attr.to_s
      if method_name.end_with?(*integer_suffixes)
        value.to_i
      elsif method_name.end_with?(*url_suffixes)
        ::Onebox::Helpers.normalize_url_for_output(value)
      else
        value
      end
    end

    private

    def integer_suffixes
      ['width', 'height']
    end

    def url_suffixes
      ['url', 'image']
    end

    def get(attr, length = nil)
      return nil if Onebox::Helpers::blank?(og)

      value = og[attr]

      return nil if Onebox::Helpers::blank?(value)

      value = Sanitize.fragment(html_entities.decode(value)).strip
      value = Onebox::Helpers.truncate(value, length) unless length.nil?

      value
    end

    def html_entities
      @html_entities ||= HTMLEntities.new
    end

    def extract
      return {} unless doc

      og = {}

      doc.css('meta').each do |m|
        if (m["property"] && m["property"][/^(?:og|article|product):(.+)$/i]) || (m["name"] && m["name"][/^(?:og|article|product):(.+)$/i])
          value = (m["content"] || m["value"]).to_s
          og[$1.tr('-:', '_').to_sym] ||= value unless Onebox::Helpers::blank?(value)
        end
      end

      # Attempt to retrieve the title from the meta tag
      title_element = doc.at_css('title')
      if title_element && title_element.text
        og[:title] ||= title_element.text unless Onebox::Helpers.blank?(title_element.text)
      end

      og
    end

  end
end
