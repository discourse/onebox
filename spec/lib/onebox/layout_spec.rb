require "spec_helper"

describe Onebox::Layout do
  let(:cache) { Moneta.new(:Memory, expires: true, serializer: :json) }
  let(:record) { { link: "foo" } }
  let(:onebox) { double("Onebox") }
  let(:layout) { described_class.new("amazon", onebox) }
  let(:html) { layout.to_html }
  let(:expanded) { false }

  before(:each) do
    Onebox.options.cache.clear
    allow(onebox).to receive(:record).and_return(record)
    allow(onebox).to receive(:cache).and_return(cache)
    allow(onebox).to receive(:expanded).and_return(expanded)
  end

  describe ".template_path" do
    let(:template_path) { layout.template_path }

    before(:each) do
      Onebox.options.load_paths << "directory_a"
      Onebox.options.load_paths << "directory_b"
    end

    context "when template exists in directory_b" do
      before(:each) do
        allow_any_instance_of(described_class).to receive(:has_template?) do |path|
          path == "directory_b"
        end
      end

      it "returns directory_b" do
        expect(template_path).to eq("directory_b")
      end
    end

    context "when template exists in directory_a" do
      before(:each) do
        allow_any_instance_of(described_class).to receive(:has_template?) do |path|
          path == "directory_a"
        end
      end

      it "returns directory_a" do
        expect(template_path).to eq("directory_a")
      end
    end

    context "when template doesn't exist in directory_a or directory_b" do
      it "returns default path" do
        expect(template_path).to include("template")
      end
    end
    
    after(:each) do
      Onebox.options.load_paths.pop(2)
    end
  end

  describe "#to_html" do
    class OneboxEngineLayout
      include Onebox::Engine

      def data
        "new content"
      end
    end

    it "reads from cache if rendered template is cached" do
      described_class.new("amazon", onebox).to_html
      expect(cache).to receive(:fetch)
      described_class.new("amazon", onebox).to_html
    end

    it "stores rendered template if it isn't cached" do
      expect(cache).to receive(:store)
      described_class.new("wikipedia", onebox).to_html
    end

    it "contains layout template" do
      expect(html).to include(%|class="onebox|)
    end

    it "contains the view" do
      html = described_class.new("amazon", onebox).to_html
      expect(html).to include(%|"foo"|)
    end
  end
end
