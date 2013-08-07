require "spec_helper"

describe Discourse::Oneboxer::Preview do
  describe "#to_s" do
    it "returns some html if given a valid url" do
      fake("http://www.example.com", response("example.response"))
      preview = described_class.new("http://www.example.com")
      expect(preview.to_s).to include("<h1>Example Domain 1</h1>")
    end
    it "returns an empty string if the resource is not found"
    it "returns an empty string if the resource fails to load"
    it "returns an empty string if the url is not valid"
  end
end
