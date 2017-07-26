require 'spec_helper'

describe Onebox::Engine::GoogleDriveOnebox do
  before do
    fake("https://drive.google.com/file/d/0Bz_47yXhlsjRRkluaTFjc09IaVU/view", response("googledrive-video"))
  end

  it "creates a link to the shared file" do
    result =  <<-HTML
<a href="https://drive.google.com/file/d/0Bz_47yXhlsjRRkluaTFjc09IaVU/view?usp=embed_facebook" target="_blank" rel="nofollow noopener">
  <img alt="GoogleDrive" title="2012-05-06 10.55.14.mov" src="https://lh3.googleusercontent.com/sRKiJr6ad4gECbrAHusUuK38yCAPeOShQ-8CB6B6E1rHIarBf6UGXw=w1200-h630-p" width="1200" height="630">
</a>
HTML
    expect(Onebox.preview('https://drive.google.com/file/d/0Bz_47yXhlsjRRkluaTFjc09IaVU/view').to_s.strip).to eq(result.strip)
  end
end
