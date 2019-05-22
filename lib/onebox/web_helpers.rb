# frozen_string_literal: true

module Onebox
  module WebHelpers
    def root_path
      "#{env['SCRIPT_NAME']}/"
    end
  end
end
