require "spec_helper"
describe Onebox::Engine::KalturaOnebox do
  it "Has entry ID" do
    expect(Onebox.preview('http://www.kaltura.com/tiny/sj0h8').to_s).to match(/"entry_id": "([0-9a-z_]+)"/)
  end
  it "Has uiconf ID" do
    expect(Onebox.preview('http://www.kaltura.com/index.php/extwidget/preview/partner_id/1829791/uiconf_id/32334692/entry_id/1_ddrwr3yz/embed/auto?&flashvars[streamerType]=auto').to_s).to match(/"uiconf_id": ([0-9]+)/)
  end
  it "Has embedIframeJs" do
    expect(Onebox.preview('http://www.kaltura.com/index.php/extwidget/preview/partner_id/1829791/uiconf_id/32334692/entry_id/1_ddrwr3yz/embed/auto?&flashvars[streamerType]=auto').to_s).to match(/"<script src=".*\/embedIframeJs\//)
  end
end
