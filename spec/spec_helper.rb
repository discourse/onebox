require "coveralls"
Coveralls.wear! do
  add_filter "/spec/"
end

require "rspec"
require "pry"
require "fakeweb"
require "onebox"
require 'mocha/api'

require_relative "support/html_spec_helper"

RSpec.configure do |config|
  config.include HTMLSpecHelper
end

shared_context "engines" do
  before(:each) do
    fake(@uri || @link, response(described_class.onebox_name))
    @onebox = described_class.new(@link)
    @html = @onebox.to_html
    @data = @onebox.send(:data)
    Onebox.options.cache.clear
  end

  let(:onebox) { @onebox }
  let(:html) { @html }
  let(:data) { @data }
  let(:link) { @link }

  def escaped_data(key)
    CGI.escapeHTML(data[key])
  end
end

shared_examples_for "an engine" do
  it "responds to data" do
    expect(described_class.private_instance_methods).to include(:data)
  end

  it "responds to record" do
    expect(onebox).to respond_to(:record)
  end

  it "correctly matches the url" do
    onebox = Onebox::Matcher.new(link).oneboxed
    expect(onebox).to be(described_class)
  end

  describe "#data" do
    it "includes title" do
      expect(data[:title]).not_to be_nil
    end

    it "includes link" do
      expect(data[:link]).not_to be_nil
    end

    it "includes badge" do
      expect(data[:badge]).not_to be_nil
    end

    it "includes domain" do
      expect(data[:domain]).not_to be_nil
    end
  end
end

shared_examples_for "a layout engine" do
  describe "#to_html" do
    it "includes subname" do
      expect(html).to include(%|<aside class="onebox #{described_class.onebox_name}">|)
    end

    it "includes title" do
      expect(html).to include(escaped_data(:title))
    end

    it "includes link" do
      expect(html).to include(%|class="link" href="#{data[:link]}|)
    end

    it "includes badge" do
      expect(html).to include(%|<strong class="name">#{data[:badge]}</strong>|)
    end

    it "includes domain" do
      expect(html).to include(%|class="domain" href="#{escaped_data(:domain)}|)
    end
  end
end
