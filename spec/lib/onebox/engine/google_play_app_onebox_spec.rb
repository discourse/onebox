require "spec_helper"

describe Onebox::Engine::GooglePlayAppOnebox do
  before(:all) do
    @link = "https://play.google.com/store/apps/details?id=com.hulu.plus&hl=en"
    fake("https://play.google.com/store/apps/details?id=com.hulu.plus&hl=en", response("googleplayapp"))
  end

  include_context "engines"
  it_behaves_like "an engine"

  describe "#to_html" do
    it "has title" do
      expect(html).to include("Hulu: Stream TV, Movies &amp; more")
    end

    it "has image" do
      expect(html).to include("4iScc4heC5Cog-i-es2hIYe0RuewYTkGiJfHAaXv0Kb2Q5b2qpbYWxWiooAPuUEhpg")
    end

    it "has description" do
      expect(html).to include("Enjoy all your TV in one place with a new Hulu experience")
    end

    it "has price" do
      expect(html).to include("Free")
    end
  end
end
