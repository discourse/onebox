require_relative "preview/example"
require_relative "preview/amazon"
<<<<<<< HEAD
require_relative "preview/stackexchange"
require_relative "preview/qik"
=======
>>>>>>> parent of 150f64f... require stackexchange, match stackexchange.com to stackexchange

module Onebox
  class Preview
    def initialize(link)
      @url = link
      @resource = open(@url)
      @document = Nokogiri::HTML(@resource)
    end

    def to_s
      case @url
      when /example\.com/ then Example
      when /amazon\.com/ then Amazon
      when /qik\.com/ then Qik
      end.new(@document, @url).to_html
    end

    class InvalidURI < StandardError

    end
  end
end

