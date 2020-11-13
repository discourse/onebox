# frozen_string_literal: true

require "spec_helper"

describe Onebox::Engine::InstagramOnebox do
  let(:link) { "https://www.instagram.com/p/CARbvuYDm3Q/" }
  let(:api_link) { "https://api.instagram.com/oembed/?url=https://www.instagram.com/p/CARbvuYDm3Q" }
  let(:html) { described_class.new(link, facebook_app_access_token: 'abc123').to_html }

  before do
    fake(api_link, response("instagram"))
  end

  it "includes title" do
    expect(html).to include('<a href="https://www.instagram.com/p/CARbvuYDm3Q" target="_blank" rel="noopener">@natgeo</a>')
  end

  it "includes image" do
    expect(html).to include("https://scontent.cdninstagram.com/v/t51.2885-15/sh0.08/e35/s640x640/97565241_163250548553285_9172168193050746487_n.jpg?_nc_ht=scontent.cdninstagram.com&amp;_nc_cat=105&amp;_nc_ohc=vB8ohQI9gdQAX-9XcIT&amp;_nc_tp=24&amp;oh=76fa4b23fb794941d483279777ee50b7&amp;oe=5FD59F36")
  end

  it 'oneboxes links that include the username' do
    link_with_profile = 'https://www.instagram.com/bennyblood24/p/CARbvuYDm3Q/'
    onebox_klass = Onebox::Matcher.new(link_with_profile).oneboxed
    expect(onebox_klass.name).to eq(described_class.name)
  end

  it 'oneboxes photo links' do
    photo_link = 'https://www.instagram.com/p/CARbvuYDm3Q/'
    onebox_klass = Onebox::Matcher.new(photo_link).oneboxed
    expect(onebox_klass.name).to eq(described_class.name)
  end
end
