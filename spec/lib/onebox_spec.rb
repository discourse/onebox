require "spec_helper"

describe Onebox do

  before do
    fake("http://www.amazon.com", response("amazon"))
  end

  describe ".preview" do
    let(:url) { "http://www.amazon.com/product" }
    it "creates a cache that responds as expected" do
      preview = Onebox.preview(url)
      cache = preview.cache
      expect(cache).to respond_to(:key?, :store, :fetch)
    end

    it "stores the value in cache if it doesn't exist" do
      preview = Onebox.preview(url)
      preview.to_s
      cache = preview.cache
      expect(cache.key?(url)).to eq(true)
    end

    it "replaces the cache if the cache is expired" do
      preview = Onebox.preview(url, cache: Moneta.new(:Memory, expires: 100_000, serializer: :json))
      cache = preview.cache
      expect(cache.fetch(url)).to be(nil)
    end
  end

  describe "templates" do
    let(:ignored)  { ["templates/_layout.mustache", "templates/githubgist.mustache", "templates/githubblob.mustache"] }
    let(:templates) { Dir["templates/*.mustache"] - ignored }

    def expect_templates_to_not_match(text)
      templates.each do |template|
        expect(File.read(template)).not_to match(text)
      end
    end

    it "should not contain any script tags" do
      expect_templates_to_not_match(/<script/)
    end
  end

  describe 'has_matcher?' do
    before do
      Onebox::Engine::WhitelistedGenericOnebox.whitelist = %w(youtube.com)
    end
    it "has no matcher for a made up url" do
      expect(Onebox.has_matcher?("http://wow.com/omg/doge")).to be_false
    end

    it "has a matcher for a real site" do
      expect(Onebox.has_matcher?("http://www.youtube.com/watch?v=azaIE6QSMUs")).to be_true
    end
  end
end
