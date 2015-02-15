require "spec_helper"

describe Onebox::Engine::FacebookOnebox do
  # Facebook need to use graph api
  # Please set ENV["FACEBOOK_APP_ID"] and ENV["FACEBOOK_APP_SECRET"] to pass the test.
  before(:all) do
    FakeWeb.allow_net_connect = true
   end

  describe "fanpage-post" do
    before(:all) do
      @link = "https://www.facebook.com/Appendectomy/posts/377534625764919"
    end

    if ENV["FACEBOOK_APP_ID"] and ENV["FACEBOOK_APP_SECRET"]

      include_context "engines"
      it_behaves_like "an engine"

      it "#title" do
        expect(html).to include("嗨！你投票了嗎？")
      end

      it "#content" do
        expect(html).to include("電鈴部隊出動中")
      end

      it "#comment author" do
        expect(html).to include("Basara Nekki")
      end

      it "#comment content" do
        expect(html).to include("剛割完，通體順暢")
      end
    else
      it "#do nothing" do
        Onebox.preview(@link).to_s.should eq("")
      end
    end
  end


  describe "fanpage-photo" do
    before(:all) do
      @link = "https://www.facebook.com/Appendectomy/photos/a.249135138604869.1073741828.248848828633500/377489712436077/"
    end

    if ENV["FACEBOOK_APP_ID"] and ENV["FACEBOOK_APP_SECRET"]

      include_context "engines"
      it_behaves_like "an engine"

      it "#title" do
        expect(html).to include("我們是割闌尾計畫")
      end

      it "#content" do
        expect(html).to include("台灣罷免歷史上不會被忘記的一天")
      end

      it "#comment author" do
        expect(html).to include("初春飾利")
      end

      it "#comment content" do
        expect(html).to include("一路走來也見識到制罷免法有多們可笑")
      end
    else
      it "#do nothing" do
        Onebox.preview(@link).to_s.should eq("")
      end
    end
  end

  describe "user-photo" do
    before(:all) do
      @link = "https://www.facebook.com/photo.php?fbid=10205727804771336&set=a.4811161873909.2192213.1142107210"
    end

    if ENV["FACEBOOK_APP_ID"] and ENV["FACEBOOK_APP_SECRET"]

      include_context "engines"
      it_behaves_like "an engine"

      it "#title" do
        expect(html).to include("黨產解密全書公開")
      end

      it "#content" do
        expect(html).to include("由於該書作者已拋棄著作權，因此在此開放出來給大家閱讀，讓大家全面的了解黨產問題。")
      end

      it "#comment author" do
        expect(html).to include("勇吉")
      end

      it "#comment content" do
        expect(html).to include("要被查水錶了")
      end
    else
      it "#do nothing" do
        Onebox.preview(@link).to_s.should eq("")
      end
    end
  end
end