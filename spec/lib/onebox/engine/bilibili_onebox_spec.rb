# frozen_string_literal: true

require "spec_helper"

describe Onebox::Engine::BiliBiliOnebox do

  let(:link) { "https://www.bilibili.com/video/BV1Js411o76u" }
  let(:avlink) { "https://www.bilibili.com/video/av810872" } #just same to bv link
  let(:outlink) { "https://player.bilibili.com/player.html?aid=810872&amp;page=1&amp;as_wide=1" }
  let(:html) { described_class.new(link).to_html }
  let(:avhtml) { described_class.new(avlink).to_html }

  describe "#to_html" do

    # the player.bilibili.com already have a window for iframe
    it "is bv url correct" do
      expect(html).to include(outlink)
    end
    it "is av url correct" do
      expect(avhtml).to include(outlink)
    end
  end
end
