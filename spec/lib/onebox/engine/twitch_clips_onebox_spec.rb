# frozen_string_literal: true

require 'spec_helper'

describe Onebox::Engine::TwitchClipsOnebox do
  let(:hostname) { 'www.example.com' }
  let(:options) { { hostname: hostname } }

  it "has the iframe with the correct channel" do
    expect(Onebox.preview('https://clips.twitch.tv/FunVastGalagoKlappa', options).to_s).to match(/<iframe src="https:\/\/clips\.twitch\.tv\/embed\?clip=FunVastGalagoKlappa&amp;parent=#{hostname}/)
  end

end
