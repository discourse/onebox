module Onebox
  module Engine
    class SpreadsheetOnebox
      include Engine

      matches_regexp /^(https?:)?\/\/(docs\.google\.[\w.]{2,}|goo\.gl)\/(spreadsheet|spreadsheets)\/.+$/

      def to_html
        url = @url.split('&').first
        "<iframe src='#{url}&rm=minimal' style='border: 0' width='800' height='600' frameborder='0' scrolling='no' ></iframe>"
      end

    end
  end
end