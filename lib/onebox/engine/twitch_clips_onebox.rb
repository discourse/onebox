# frozen_string_literal: true

require_relative '../mixins/twitch_onebox'

class Onebox::Engine::TwitchClipsOnebox

  def self.twitch_regexp
    /^https?:\/\/clips\.twitch\.tv\/([a-zA-Z0-9_]+\/?[^#\?\/]+)/
  end
  include Onebox::Mixins::TwitchOnebox

  def query_params
    "clip=#{twitch_id}"
  end

  def base_url
    "clips.twitch.tv/embed?"
  end

end
