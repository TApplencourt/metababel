require_relative 'bt2_generator_utils'

module Babeltrace2Gen
  class BTValueCLass
    attr_accessor :cast_type

    def self.from_h(model)
      key = model.delete(:type)
      raise "No type in #{model}" unless key

      h = { 'map' => BTValueCLass::Map,
            'string' => BTValueCLass::String,
            'bool' => BTValueCLass::Bool,
            'integer_unsigned' => BTValueCLass::IntegerUnsigned }.freeze
      raise "Type #{key} not supported" unless h.include?(key)

      cast_type = model.delete(:cast_type)
      fc = h[key].from_h(model)
      fc.cast_type = cast_type if cast_type
      fc
    end
  end

  class BTValueCLass::Scalar < BTValueCLass
    attr_accessor :name, :usr_default_value

    include BTPrinter

    # Scalars are leaves, avoid recursion
    def self.from_h(model)
      new(model[:name], model.fetch(:default_value, nil))
    end

    def initialize(name, usr_default_value)
      @name = name
      @usr_default_value = usr_default_value
    end

    def get(name, val)
      cast_func = @cast_type ? "(#{@cast_type})" : ''
      bt_default_value = self.class.instance_variable_get(:@bt_default_value)
      bt_type = self.class.instance_variable_get(:@bt_type)
      bt_type_is = self.class.instance_variable_get(:@bt_type_is)

      default_value = @usr_default_value || bt_default_value

      pr "if (#{val} != NULL) {"
      pr "  if (!#{bt_type_is}(#{val})) {"
      pr "    fprintf(stderr,\"Bad value for command line argument '%s' the value must be '%s'. \\n\",\"#{@name}\",\"#{bt_type}\");"
      pr '    exit(1);'
      pr '  }'
      pr "  #{name} = #{cast_func}bt_value_#{bt_type}_get(#{val});"
      pr '} else {'
      pr "  #{name} = #{cast_func}#{default_value};"
      pr '}'
    end

    def get_struct_definition(_name)
        type = @cast_type || self.class.instance_variable_get(:@bt_return_type)
        "#{type} #{@name};"
    end
  end

  class BTValueCLass::Map < BTValueCLass
    @bt_type = 'struct'

    attr_accessor :name
    include BTPrinter

    def self.from_h(model)
      new(model[:name], model[:entries])
    end

    def initialize(name, entries = [])
      @name = name
      @entries = entries.collect { |m| BTValueCLass.from_h(**m) }
    end

    def get(struct, map)
      @entries.map do |m|
        scope do
          pr "const bt_value *#{m.name} = bt_value_map_borrow_entry_value_const(#{map}, \"#{m.name}\");"
          m.get("#{struct}.#{m.name}", m.name)
        end
      end
    end

    def get_struct_definition(level=0)
      a = ["struct btx_params_#{@name}_s {"]
      a += @entries.map do |e|
        e.get_struct_definition(level+1);
      end
      if level == 0
        a << "};"
        a << "typedef struct btx_params_#{@name}_s btx_params_#{@name}_t;"
      else
        a << "} #{@name};"
      end

      a.join("\n")
    end
  end

  class BTValueCLass::Bool < BTValueCLass::Scalar
    @bt_type = 'bool'
    @bt_type_is = 'bt_value_is_bool'
    @bt_return_type = 'bt_bool'
    @bt_default_value = 'BT_FALSE'

    def initialize(name, usr_default_value)
      bt_type = self.class.instance_variable_get(:@bt_type)
      if !usr_default_value.nil? && !%w[BT_TRUE BT_FALSE].include?(usr_default_value)
        raise "Bad default_value for '#{name}' in params.yaml, it must be #{bt_type} (BT_TRUE or BT_FALSE) but provided '#{usr_default_value}'."
      end

      super(name, usr_default_value)
    end
  end

  class BTValueCLass::String < BTValueCLass::Scalar
    @bt_type = 'string'
    @bt_type_is = 'bt_value_is_string'
    @bt_return_type = 'const char*'
    @bt_default_value = 'NULL'

    def initialize(name, usr_default_value)
      bt_type = self.class.instance_variable_get(:@bt_type)
      # Every object that can be converted to string is being supported.
      if !usr_default_value.nil? && !usr_default_value.respond_to?(:to_s)
        raise "Bad default_value for '#{name}' in params.yaml, it must be #{bt_type} but provided '#{usr_default_value}'."
      end

      super(name, usr_default_value.to_s.inspect)
    end
  end

  class BTValueCLass::IntegerUnsigned < BTValueCLass::Scalar
    @bt_type = 'integer_unsigned'
    @bt_type_is = 'bt_value_is_signed_integer'
    @bt_return_type = 'uint64_t'
    @bt_default_value = '0'

    def initialize(name, usr_default_value)
      bt_type = self.class.instance_variable_get(:@bt_type)
      if !usr_default_value.nil? && (!usr_default_value.is_a?(Integer) || !usr_default_value.between?(0, (2**64) - 1))
        raise "Bad default_value for '#{name}' in params.yaml, it must be #{bt_type} and must be in [0,2^64-1], but provided '#{usr_default_value}'."
      end

      super(name, usr_default_value)
    end
  end
end
