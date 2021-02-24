# frozen_string_literal: true

module Onebox
  class StatusCheck
    def initialize(url, options = Onebox.options)
      @url = url
      @options = options
      @status = -1
    end

    def ok?
      status > 199 && status < 300
    end

    def status
      check if @status == -1
      @status
    end

    def human_status
      case status
      when 0
        :connection_error
      when 200..299
        :success
      when 400..499
        :client_error
      when 500..599
        :server_error
      else
        :unknown_error
      end
    end

    private

    def check
      res = URI.open(@url, read_timeout: (@options.timeout || Onebox.options.timeout))
      @status = res.status.first.to_i
    rescue OpenURI::HTTPError => e
      @status = e.io.status.first.to_i
    rescue Timeout::Error, Errno::ECONNREFUSED, Net::HTTPError
      @status = 0
    end
  end
end
