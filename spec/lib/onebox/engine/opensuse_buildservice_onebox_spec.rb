require "spec_helper"

describe Onebox::Engine::OpensuseBuildServiceOnebox do

  context "user page" do
    let(:link) { "https://build.opensuse.org/user/show/dstoecker"}
    let(:html) { described_class.new(link).to_html }
    before do
      fake("https://build.opensuse.org/user/show/dstoecker", response("obs-user"))
    end

    describe "#to_html" do
      it "includes user's avatar" do
        expect(html).to include("https://www.gravatar.com/avatar/6b2ec66c6a7057e2d6744b539e7f8dda?s=200&amp;d=wavatar")
      end

      it "includes user's realname" do
        expect(html).to include("Dirk Stoecker")
      end

      it "includes user's username" do
        expect(html).to include("dstoecker")
      end
    end
  end

  context "request page" do
    let(:link) { "https://build.opensuse.org/request/show/643996"}
    let(:html) { described_class.new(link).to_html }
    before do
      fake("https://build.opensuse.org/request/show/643996", response("obs-request"))
      fake("https://build.opensuse.org/user/show/dstoecker", response("obs-user"))
    end

    describe "#to_html" do
      it "includes submitter's avatar" do
        expect(html).to include("https://www.gravatar.com/avatar/6b2ec66c6a7057e2d6744b539e7f8dda?s=200&amp;d=wavatar")
      end

      it "includes request number and status" do
        expect(html).to include("Request 643996 (new)")
      end

      it "includes short description of the request" do
        expect(html).to include("- Drop pre-rollover key 19036 from 2010, only leave 2017/2018")
      end

      it "includes the submitter's URL in footnote" do
        expect(html).to include("https://build.opensuse.org/user/show/dstoecker")
      end

      it "includes the relative creation date in footnote" do
        expect(html).to include("5 days ago")
      end
    end
  end

  context "project page" do
    let(:link) { "https://build.opensuse.org/project/show/server:dns" }
    let(:html) { described_class.new(link).to_html }
    before do
      fake("https://build.opensuse.org/project/show/server:dns", response("obs-project"))
    end

    describe "#to_html" do
      it "includes the project's name" do
        expect(html).to include("Domain Name System")
      end

      it "includes the project's description" do
        expect(html).to include("Packages around the Domain Name System.")
      end
    end
  end

  context "package page" do
    let(:link) { "https://build.opensuse.org/package/show/server:dns/knot" }
    let(:html) { described_class.new(link).to_html }
    before do
      fake("https://build.opensuse.org/package/show/server:dns/knot", response("obs-package"))
    end

    describe "#to_html" do
      it "includes the package's name" do
        expect(html).to include("Knot DNS")
      end

      it "includes the packages' description" do
        expect(html).to include("Knot DNS is a high-performance authoritative DNS server implementation.")
      end

      it "includes the download link for the package" do
        expect(html).to include("https://software.opensuse.org/download.html?project=server:dns&package=knot")
      end
    end
  end
end
