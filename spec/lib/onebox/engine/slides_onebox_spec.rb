# frozen_string_literal: true

require "spec_helper"

describe Onebox::Engine::SlidesOnebox do

  let(:link) { "http://slides.com/drksephy/ecmascript-2015" }
  let(:html) { described_class.new(link).to_html }

  before do
    fake(link, response("slides"))
  end

  describe "#placeholder_html" do
    it "returns an image as the placeholder" do
      expect(Onebox.preview(link).placeholder_html).to include("//s3.amazonaws.com/media-p.slid.es/thumbnails/secure/cff7c3/decks.jpg")
    end
  end

  describe "#to_html" do
    it "returns iframe embed" do
      expect(html).to include(URI(link).path)
      expect(html).to include("iframe")
    end
  end
end
