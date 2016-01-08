require "spec_helper"
describe Onebox::Engine::KalturaOnebox do
  before do
    fake("http://www.kaltura.com/tiny/sj0h8", response("kaltura"))
  end
  it "Has embedIframeJs inlcude" do
    expect(Onebox.preview('http://www.kaltura.com/tiny/sj0h8').to_s).to match(/\<script src=".*\/embedIframeJs\//)
  end
  it "Has kWidget.embed" do
    expect(Onebox.preview('http://www.kaltura.com/tiny/sj0h8').to_s).to match(/kWidget\.embed/)
  end
  it "Has entry ID" do
    expect(Onebox.preview('http://www.kaltura.com/tiny/sj0h8').to_s).to match(/"entry_id": "([0-9a-z_]+)"/)
  end
  it "Has uiconf ID" do
    expect(Onebox.preview('http://www.kaltura.com/tiny/sj0h8').to_s).to match(/"uiconf_id": ([0-9]+)/)
  end
end
