# frozen_string_literal: true

require "spec_helper"

describe Onebox do
  before do
    fake("https://www.amazon.com/product", response("amazon"))
  end

  describe "templates" do
    let(:ignored)  { ["templates/_layout.mustache"] }
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
      Onebox::Engine::AllowlistedGenericOnebox.allowed_domains = %w(youtube.com)
    end

    it "has no matcher for a made up url" do
      expect(Onebox.has_matcher?("http://wow.com/omg/doge")).to be false
    end

    it "has a matcher for a real site" do
      expect(Onebox.has_matcher?("http://www.youtube.com/watch?v=azaIE6QSMUs")).to be true
    end
  end
end
