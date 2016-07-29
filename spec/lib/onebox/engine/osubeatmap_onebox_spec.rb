require "spec_helper"

describe Onebox::Engine::OsuBeatmapOnebox do
  before(:all) do
    @link = "https://osu.ppy.sh/s/430339"
  end

  include_context "engines"
  it_behaves_like "an engine"

  before do
    fake(link, response("osubeatmap.response"))
  end

  it "has title" do
    expect(html).to include("Hatsuki Yura - Eclipse Parade (mapped by Vert)")
  end

  it "has description" do
    expect(html).to include("27th beatmap #2 for ranked")
  end

  it "has URL" do
    expect(html).to include(link)
  end
end
