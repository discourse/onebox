require "spec_helper"

class Onebox::Engine::Foo
  include Onebox::Engine

  def record
    "foo"
  end
end

describe Onebox::Engine do
  describe "#to_html" do
    it "returns formatted html"
  end

  describe "#record" do
    it "returns cache value for given url if cache exists" do
      cache = { "http://example.com" => "foo" }
      result = Onebox::Engine::Foo.new("http://example.com", cache).send(:record)
      expect(result).to eq("foo")
    end

    it "stores cache value for given url if cache key doesn't exist" do
      cache = { "http://example.com1" => "foo" }
      result = Onebox::Engine::Foo.new("http://example.com").send(:record)
      expect(result).to eq("foo")
    end
  end

  describe ".===" do
    it "returns true if argument matches the matcher" do
      class Onebox::Engine::Foo
        include Onebox::Engine
        @@matcher = /example/
      end
      result = Onebox::Engine::Foo === "http://www.example.com/product/5?var=foo&bar=5"
      expect(result).to eq(true)
    end
  end

  describe ".matches" do
    it "sets @@matcher to a regular expression" do
      class Onebox::Engine::Far
        include Onebox::Engine

        matches do
          find "foo.com"
        end
      end
      regex = Onebox::Engine::Far.class_variable_get(:@@matcher)
      expect(regex).to eq(/(?:foo\.com)/i)
    end
  end
end
