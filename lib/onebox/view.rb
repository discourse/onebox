module Onebox
  class View < Mustache
    attr_reader :record

    self.template_path = Onebox.options.load_paths.last

    def initialize(name, record, expanded)
      @record = record
      self.template_name = if expanded 
        "#{name}_expanded"
      else
        name
      end
    end

    def to_html
      render(record)
    end
  end
end
