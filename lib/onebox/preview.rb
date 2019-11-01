# frozen_string_literal: true

module Onebox
  class Preview

    # see https://bugs.ruby-lang.org/issues/14688
    client_exception = defined?(Net::HTTPClientException) ? Net::HTTPClientException : Net::HTTPServerException
    WEB_EXCEPTIONS ||= [client_exception, OpenURI::HTTPError, Timeout::Error, Net::HTTPError, Errno::ECONNREFUSED]

    def initialize(link, parameters = Onebox.options)
      @url = link
      @options = parameters
      @engine_class = Matcher.new(@url).oneboxed
    end

    def to_s
      return "" unless engine
      sanitize process_html engine_html
    rescue *WEB_EXCEPTIONS
      ""
    end

    def placeholder_html
      return "" unless engine
      sanitize process_html engine.placeholder_html
    rescue *WEB_EXCEPTIONS
      ""
    end

    def options
      OpenStruct.new(@options)
    end

    private

    def engine_html
      engine.to_html
    end

    def process_html(html)
      return "" unless html

      if @options[:max_width]
        doc = Nokogiri::HTML::fragment(html)
        if doc
          doc.css('[width]').each do |e|
            width = e['width'].to_i

            if width > @options[:max_width]
              height = e['height'].to_i
              if (height > 0)
                ratio = (height.to_f / width.to_f)
                e['height'] = (@options[:max_width] * ratio).floor
              end
              e['width'] = @options[:max_width]
            end
          end
          return doc.to_html
        end
      end

      html
    end

    def sanitize(html)
      Sanitize.fragment(html, @options[:sanitize_config] || Sanitize::Config::ONEBOX)
    end

    def engine
      return nil unless @engine_class
      return @engine if @engine

      @engine = @engine_class.new(@url)
      @engine.options = @options
      @engine
    end

    class InvalidURI < StandardError; end
  end
end
