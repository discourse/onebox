require "spec_helper"

describe Onebox::Engine::ImdbOnebox do
  before(:all) do
    @link = "http://www.imdb.com/title/tt0944947"
    fake("http://www.imdb.com/title/tt0944947", response(described_class.onebox_name))
  end

  include_context "engines"
  it_behaves_like "an engine"

  describe "#to_html" do
    it "includes title" do
      expect(html).to include("Game of Thrones")
    end

    it "includes description" do
      expect(html).to include("Nine noble families fight for control over the mythical lands of Westeros")
    end

    it "includes image" do
      expect(html).to include("https://images-na.ssl-images-amazon.com/images/M/MV5BMjE3NTQ1NDg1Ml5BMl5BanBnXkFtZTgwNzY2NDA0MjI@._V1_UY1200_CR90,0,630,1200_AL_.jpg")
    end
  end
end
