require "open-uri"
require "multi_json"
require "nokogiri"
require "mustache"
require "opengraph_parser"

require_relative "onebox/version"
require_relative "onebox/preview"
require_relative "onebox/matcher"
require_relative "onebox/engine"

module Onebox
  def self.preview(url, args={})
    Preview.new(url, args)
  end
end
