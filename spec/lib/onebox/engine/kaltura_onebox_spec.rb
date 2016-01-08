require "spec_helper"

describe Onebox::Engine::KalturaOnebox do
  let(:link) { "http://www.kaltura.com" }
  let(:html) { described_class.new(link).to_html }

  before do
    fake(link, response("name.response"))
  end

  it "has the video's title" do
    expect(html).to include("title")
  end

  it "has the video's still shot" do
    expect(html).to include("photo.jpg")
  end

  it "has the video's description" do
    expect(html).to include("description")
  end

  it "has the URL to the resource" do
    expect(html).to include(link)
  end
end
