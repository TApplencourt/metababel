module Babeltrace2Gen
  module BTPrinter
    @@output = ''
    @@indent = 0
    INDENT_INCREMENT = '  '.freeze

    def pr(str)
      @@output << (INDENT_INCREMENT * @@indent) << str << "\n"
    end
    module_function :pr

    def scope
      pr '{'
      @@indent += 1
      yield
      @@indent -= 1
      pr '}'
    end

    def self.context(output: '', indent: 0)
      @@output = output
      @@indent = indent
      yield
      @@output
    end

    # Maybe not the best place
    def name_sanitized
      raise unless @name

      @name.gsub(/[^0-9A-Za-z-]/, '_')
    end
  end

  def self.context(**args, &block)
    BTPrinter.context(**args, &block)
  end
end
