# frozen_string_literal: true

require "spec_helper"

describe Onebox::Engine::BiliBiliOnebox do

  let(:link) { "https://www.bilibili.com/video/av810872" }
  let(:html) { described_class.new(link).to_html }

  describe "#to_html" do

    # player.bilibili.com already have a window for iframe
    it "has the url" do
      expect(html).to include("https://player.bilibili.com")
    end
  end
end
