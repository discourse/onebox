# frozen_string_literal: true

require "spec_helper"

describe Onebox::Engine::GithubPullRequestOnebox do
  before(:all) do
    @link = "https://github.com/discourse/discourse/pull/1253/"
    @uri = "https://api.github.com/repos/discourse/discourse/pulls/1253"
    fake(@uri, response(described_class.onebox_name))
  end

  include_context "engines"
  it_behaves_like "an engine"

  describe "#to_html" do
    it "includes pull request author" do
      expect(html).to include("jamesaanderson")
    end

    it "includes repository name" do
      expect(html).to include("discourse")
    end

    it "includes commit author gravatar" do
      expect(html).to include("b3e9977094ce189bbb493cf7f9adea21")
    end

    it "includes commit time and date" do
      expect(html).to include("02:05AM - 26 Jul 13")
    end

    it "includes number of commits" do
      expect(html).to include("1")
    end

    it "includes number of files changed" do
      expect(html).to include("4")
    end

    it "includes number of additions" do
      expect(html).to include("19")
    end

    it "includes number of deletions" do
      expect(html).to include("1")
    end
  end
end
