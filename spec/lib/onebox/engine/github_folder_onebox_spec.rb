# frozen_string_literal: true

require "spec_helper"

describe Onebox::Engine::GithubFolderOnebox do
  context 'without fragments' do
    before(:all) do
      @link = "https://github.com/discourse/discourse/tree/master/spec/fixtures"
      @uri = "https://github.com/discourse/discourse/tree/master/spec/fixtures"
      fake(@uri, response(described_class.onebox_name))
    end

    include_context "engines"
    it_behaves_like "an engine"

    describe "#to_html" do
      it "includes link to folder with truncated display path" do
        expect(html).to include("<a href=\"https://github.com/discourse/discourse/tree/master/spec/fixtures\" target=\"_blank\" rel=\"noopener\">master/spec/fixtures</a>")
      end

      it "includes repository name" do
        expect(html).to include("discourse/discourse")
      end

      it "includes logo" do
        expect(html).to include("")
      end

    end
  end

  context 'with fragments' do
    before do
      @link = "https://github.com/discourse/discourse#setting-up-discourse"
      @uri = "https://github.com/discourse/discourse"
      fake(@uri, response("githubfolder-discourse-root"))
      @onebox = described_class.new(@link)
    end

    it "extracts subtitles when linking to docs" do
      expect(@onebox.to_html).to include("<a href=\"https://github.com/discourse/discourse#setting-up-discourse\" target=\"_blank\" rel=\"noopener\">discourse/discourse - Setting up Discourse</a>")
    end
  end

end
