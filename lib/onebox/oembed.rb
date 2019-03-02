module Onebox
  class Oembed < OpenGraph

    def initialize(response)
      @data = Onebox::Helpers.symbolize_keys(::MultiJson.load(response))
    end

  end
end
