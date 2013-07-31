require "open-uri"
require "multi_json"
require "nokogiri"
require "mustache"

require_relative "oneboxer/version"

module Oneboxer
  def self.preview(link, options = {})
    Preview.new(link, options).to_s
  end
end
