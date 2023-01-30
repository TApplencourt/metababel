require 'yaml'
require_relative 'bt2_meta_utils'

module Babeltrace2Gen

class BTValueCLass
   attr_accessor :cast_type
   def self.from_h(model)
      key = model.delete(:type)
      raise "No type in #{model}" unless key

      h = {"map" => BTValueCLass::Map,
           "string" => BTValueCLass::String,
           "bool" => BTValueCLass::Bool,
           "integer_unsigned" => BTValueCLass::IntegerUnsigned
      }.freeze
      raise "Type #{key} not supported" unless h.include?(key)

      cast_type = model.delete(:cast_type)
      fc = h[key].from_h(model)
      fc.cast_type = cast_type if cast_type
      fc
   end
end

class BTValueCLass::Scalar < BTValueCLass
   attr_accessor :name
   include BTPrinter

   # Scalars are leafs, avoid recursion
   def self.from_h(model)
      new(model[:name])
   end

   def initialize(name)
      @name = name
   end

   def get(name, val)
    cast_func = @cast_type ? "(#{@cast_type})" : ''
    bt_default_value = self.class.instance_variable_get(:@bt_default_value)
    bt_type = self.class.instance_variable_get(:@bt_type)
    bt_type_is = self.class.instance_variable_get(:@bt_type_is)

    pr "if (#{val} && #{bt_type_is}(#{val}))"
    pr "  #{name} = #{cast_func}bt_value_#{bt_type}_get(#{val});"
    pr "else"
    pr "  #{name} = #{cast_func}#{bt_default_value};"
   end

end

class BTValueCLass::Map < BTValueCLass
  include BTPrinter
     
  def self.from_h(model)
      new(model[:entries])
  end

  def initialize(entries=[])
    @entries = entries.collect { |m| BTValueCLass.from_h(**m) }	
  end

  def get(struct, map)
    @entries.map { |m|
     scope do
       pr "const bt_value *val = bt_value_map_borrow_entry_value_const(#{map}, \"#{m.name}\");"
       m.get("#{struct}->#{m.name}", "val")
     end
    }
  end

  def get_struct_definition(name)
   @entries.map { |e|
     type = e.cast_type ? e.cast_type : e.class.instance_variable_get(:@bt_return_type)
     "  #{type} #{e.name};"
   }.join("\n")
  end

end

class BTValueCLass::Bool < BTValueCLass::Scalar
   @bt_type = 'bool'
   @bt_type_is = 'bt_value_is_bool'
   @bt_return_type = 'bt_bool'
   @bt_default_value= 'BT_FALSE'
end

class BTValueCLass::String < BTValueCLass::Scalar
   @bt_type = 'string'
   @bt_type_is = 'bt_value_is_string'
   @bt_return_type = 'const char*'
   @bt_default_value = "NULL"
end

class BTValueCLass::IntegerUnsigned < BTValueCLass::Scalar
   @bt_type = 'integer_unsigned'
   @bt_type_is = 'bt_value_is_signed_integer'
   @bt_return_type='uint64_t'
   @bt_default_value = '0'
end

end
