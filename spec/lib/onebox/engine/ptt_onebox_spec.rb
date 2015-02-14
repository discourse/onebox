require "spec_helper"

describe Onebox::Engine::PttOnebox do

  include_context "engines"
  it_behaves_like "an engine"

  describe "gossiping work" do
    before(:all) do
      @link = "https://www.ptt.cc/bbs/Gossiping/M.1421846278.A.824.html"
    end

    it "#title"
      expect(html).to include("清查不當黨產展覽展件資料公開")
    end

    it "#content"
      expect(html).to include("清查不當黨產 捍衛國家資產")
    end

    it "comment author"
      expect(html).to include("cttw19")
    end

    it "comment content"
      expect(html).to include("國民黨不倒 台灣不會好")
    end
  end

  describe "others work" do
    before(:all) do
      @link = "https://www.ptt.cc/bbs/PublicIssue/M.1421063009.A.F39.html"
    end

    it "#title"
      expect(html).to include("剝蕉案(青果社事件)")
    end

    it "#content"
      expect(html).to include("國父紀念館興建(跟農民勒索！)和外貿協會成立，青果社均贊助龐大費用")
    end

    it "comment author"
      expect(html).to include("aa789")
    end

    it "comment content"
      expect(html).to include("好文不推嗎？")
    end
  end
end