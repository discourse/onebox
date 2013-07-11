module Discourse
	module Oneboxer
	  class ViddlerOnebox < OembedOnebox

	    matcher /^https?:\/\/(?:www\.)?viddler\.com\/.+$/

	    def oembed_endpoint
	      "http://lab.viddler.com/services/oembed/?url=#{BaseOnebox.uriencode(@url)}"
	    end

	  end
	end
end