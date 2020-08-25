# frozen_string_literal: true

require 'spec_helper'

describe Onebox::Engine::TwitchVideoOnebox do
  let(:hostname) { 'www.example.com' }
  let(:options) { { hostname: hostname } }

  it "has the iframe with the correct channel" do
    expect(Onebox.preview('https://www.twitch.tv/videos/140675974', options).to_s).to match(/<iframe src="https:\/\/player\.twitch\.tv\/\?video=v140675974&amp;parent=#{hostname}/)
  end
end
