# frozen_string_literal: true

require "spec_helper"

describe Onebox::Engine do
  class OneboxEngineExample
    include Onebox::Engine

    def to_html
      "Hello #{link}"
    end

    def data
      { foo: raw[:key], url: @url }
    end

    def raw
      { key: "value" }
    end
  end

  describe "#link" do
    before { allow(Onebox::View).to receive(:template) { %|this should be a template| } }

    it "escapes `link`" do
      html = OneboxEngineExample.new(%|http://foo.com/bar?a='&b=2|).to_html
      expect(html).not_to match(/'/)
    end
  end

  describe '.placeholder_html' do
    let(:onebox) { OneboxEngineExample.new('http://eviltrout.com') }
    it "returns `to_html` by default" do
      expect(onebox.to_html).to eq(onebox.placeholder_html)
    end
  end

  describe ".===" do
    class OneboxEngineTripleEqual
      include Onebox::Engine
      @@matcher = /example/
    end
    it "returns true if argument matches the matcher" do
      result = OneboxEngineTripleEqual === URI("http://www.example.com/product/5?var=foo&bar=5")
      expect(result).to eq(true)
    end
  end

  class AlwaysHttpsEngineExample < OneboxEngineExample
    always_https
  end

  describe "always_https" do
    it "never returns a plain http url" do
      url = 'http://play.google.com/store/apps/details?id=com.google.android.inputmethod.latin'
      onebox = AlwaysHttpsEngineExample.new(url)
      result = onebox.to_html
      expect(result).to_not match(/http(?!s)/)
      expect(result).to_not match(/['"]\/\//)
      expect(result).to match(/https/)
    end
  end
end

describe ".onebox_name" do
  module ScopeForTemplateName
    class TemplateNameOnebox
      include Onebox::Engine
    end
  end

  let(:onebox_name) { ScopeForTemplateName::TemplateNameOnebox.onebox_name }

  it "should not include the scope" do
    expect(onebox_name).not_to include("ScopeForTemplateName", "scopefortemplatename")
  end

  it "should not include the word Onebox" do
    expect(onebox_name).not_to include("onebox", "Onebox")
  end
end
