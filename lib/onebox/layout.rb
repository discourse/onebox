module Onebox
  class Layout < Mustache
    extend Forwardable
    VERSION = "1.0.0"

    def_delegator :@onebox, :cache
    def_delegator :@onebox, :record
    def_delegator :@onebox, :expanded

    attr_reader :view

    def initialize(name, onebox)
      @onebox = onebox
      @md5 = Digest::MD5.new
      @view = View.new(name, record, expanded)
      @template_name = "_layout"
      @template_path = load_paths.last
    end

    def to_html
      if cache.key?(checksum)
        cache.fetch(checksum)
      else
        cache.store(checksum, render(details))
      end
    end

    private

    def load_paths
      Onebox.options.load_paths.select(&method(:has_template?))
    end

    def has_template?(path)
      File.exist?(File.join(path, "#{template_name}.#{template_extension}"))
    end

    def checksum
      @md5.hexdigest("#{VERSION}:#{link}")
    end

    def link
      record[:link]
    end

    def details
      {
        link: record[:link],
        title: record[:title],
        badge: record[:badge],
        domain: record[:domain],
        subname: view.template_name,
        view: view.to_html
      }
    end
  end
end
