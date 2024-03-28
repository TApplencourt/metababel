require_relative 'bt2_generator_utils'
require_relative 'bt2_matching_utils'

module HashRefinements
  refine Hash do
    def fetch_append(key, item)
      self[key] = fetch(key, []) << item
      item
    end
  end
end

module Babeltrace2Gen
  class GeneratedArg < Struct.new(:type, :name)
  end

  module BTFromH
    def from_h(parent, model)
      new(parent: parent, **model)
    end
  end

  module BTUtils
    def bt_set_conditionally(guard)
      yield guard ? 'BT_TRUE' : 'BT_FALSE' unless guard.nil?
    end
  end

  module BTLocator
    attr_reader :parent, :variable

    def rec_trace_class
      is_a?(Babeltrace2Gen::BTTraceClass) ? self : @parent.rec_trace_class
    end

    def rec_stream_class
      is_a?(Babeltrace2Gen::BTStreamClass) ? self : @parent.rec_stream_class
    end

    def rec_event_class
      is_a?(Babeltrace2Gen::BTEventClass) ? self : @parent.rec_event_class
    end

    def rec_menber_class
      is_a?(Babeltrace2Gen::BTMemberClass) ? self : @parent.rec_menber_class
    end

    def resolve_path(path)
      root, id = path.match(/^(PACKET_CONTEXT|EVENT_COMMON_CONTEXT|EVENT_SPECIFIC_CONTEXT|EVENT_PAYLOAD)\["?(.+)?"\]/).captures
      field_class =
        case root
        when 'PACKET_CONTEXT'
          rec_stream_class.packet_context_field_class
        when 'EVENT_COMMON_CONTEXT'
          rec_stream_class.event_common_context_field_class
        when 'EVENT_SPECIFIC_CONTEXT'
          rec_event_class.specific_context_field_class
        when 'EVENT_PAYLOAD'
          rec_event_class.payload_field_class
        else
          raise "invalid path #{path}"
        end
      [field_class, id]
    end
  end

  #  ______ _____   _____ _
  #  | ___ \_   _| /  __ \ |
  #  | |_/ / | |   | /  \/ | __ _ ___ ___  ___  ___
  #  | ___ \ | |   | |   | |/ _` / __/ __|/ _ \/ __|
  #  | |_/ / | |   | \__/\ | (_| \__ \__ \  __/\__ \
  #  \____/  \_/    \____/_|\__,_|___/___/\___||___/
  #
  class BTTraceClass
    include BTLocator
    include BTPrinter
    include BTUtils
    include BTMatch
    extend BTFromH

    BT_MATCH_ATTRS = [:environment]

    attr_reader :stream_classes, :environment, :assigns_automatic_stream_class_id, :match

    def initialize(parent:, stream_classes:, environment: nil, assigns_automatic_stream_class_id: nil, match: false)
      raise if parent

      # match indicate if this model will be used to match another.
      @match = match
      @parent = nil
      @assigns_automatic_stream_class_id = assigns_automatic_stream_class_id
      @environment = BTEnvironmentClass.from_h(self, environment) if environment
      @stream_classes = stream_classes.collect.with_index do |m, i|
        if m[:id].nil? != (@assigns_automatic_stream_class_id.nil? || @assigns_automatic_stream_class_id)
          raise "Incoherence between trace::assigns_automatic_stream_class_id and stream_class[#{i}]::id"
        end

        BTStreamClass.from_h(self, m)
      end
    end

    def get_declarator(variable:, self_component:)
      pr "#{variable} = bt_trace_class_create(#{self_component});"
      bt_set_conditionally(@assigns_automatic_stream_class_id) do |v|
        pr "bt_trace_class_set_assigns_automatic_stream_class_id(#{variable}, #{v});"
      end

      @stream_classes.each_with_index do |m, i|
        stream_class_name = "#{variable}_sc_#{i}"
        scope do
          pr "bt_stream_class *#{stream_class_name};"
          m.get_declarator(variable: stream_class_name, self_component: self_component, trace_class: variable)
        end
      end
    end
  end

  class BTStreamClass
    include BTUtils
    include BTPrinter
    include BTLocator
    include BTMatch
    extend BTFromH

    BT_MATCH_ATTRS = %i[parent name packet_context_field_class event_common_context_field_class
                        default_clock_class]

    attr_reader :packet_context_field_class, :event_common_context_field_class, :event_classes, :default_clock_class,
                :id, :name, :get_getter

    def initialize(parent:, name: nil, packet_context_field_class: nil, event_common_context_field_class: nil,
                   event_classes: [], id: nil, assigns_automatic_event_class_id: nil, assigns_automatic_stream_id: nil,
                   default_clock_class: nil)
      # Handle clock class property:
      #   https://babeltrace.org/docs/v2.0/libbabeltrace2/group__api-tir-clock-cls.html#gae0f705eb48cd65784da28b1906ca05a5

      @parent = parent
      @name = name

      # Should put assert to check for struct
      @packet_context_field_class = BTFieldClass.from_h(self, packet_context_field_class) if packet_context_field_class

      # Should put assert to check for struct
      if event_common_context_field_class
        @event_common_context_field_class = BTFieldClass.from_h(self,
                                                                event_common_context_field_class)
      end

      @assigns_automatic_event_class_id = assigns_automatic_event_class_id
      @event_classes = event_classes.collect do |ec|
        if ec[:id].nil? != (@assigns_automatic_event_class_id.nil? || @assigns_automatic_event_class_id.nil)
          raise 'Incorrect id scheme'
        end

        BTEventClass.from_h(self, ec)
      end
      @assigns_automatic_stream_id = assigns_automatic_stream_id
      @id = id
      @default_clock_class = default_clock_class
    end

    def get_declarator(variable:, trace_class:, self_component:)
      if @id
        pr "#{variable} = bt_stream_class_create_with_id(#{trace_class}, #{@id});"
      else
        pr "#{variable} = bt_stream_class_create(#{trace_class});"
      end
      pr "bt_stream_class_set_name(#{variable}, \"#{name}\");" if @name
      if @default_clock_class
        clock_class_name = "#{variable}_dcc"
        scope do
          pr "bt_clock_class *#{clock_class_name};"
          # TODO: @default_clock_class.get_declarator(variable: clock_class_name, self_component: self_component)
          pr "#{clock_class_name} = bt_clock_class_create(#{self_component});"
          pr "bt_stream_class_set_default_clock_class(#{variable}, #{clock_class_name});"
          pr "bt_clock_class_put_ref(#{clock_class_name});"
        end
      end

      if @packet_context_field_class
        # Support for packets required for packet_context_field_class
        # We do not support create_packet neither packet_beginning_default_clock_snapshot (BT_FALSE) nor packet_end_default_clock_snapshot (BT_FALSE)
        pr "bt_stream_class_set_supports_packets(#{variable}, BT_TRUE, BT_FALSE, BT_FALSE);"

        var_pc = "#{variable}_pc_fc"
        scope do
          pr "bt_field_class *#{var_pc};"
          @packet_context_field_class.get_declarator(trace_class: trace_class, variable: var_pc)
          pr "bt_stream_class_set_packet_context_field_class(#{variable}, #{var_pc});"
          pr "bt_field_class_put_ref(#{var_pc});"
        end
      end

      if @event_common_context_field_class
        var_ecc = "#{variable}_ecc_fc"
        scope do
          pr "bt_field_class *#{var_ecc};"
          @event_common_context_field_class.get_declarator(trace_class: trace_class, variable: var_ecc)
          pr "bt_stream_class_set_event_common_context_field_class(#{variable}, #{var_ecc});"
          pr "bt_field_class_put_ref(#{var_ecc});"
        end
      end
      # Need to do is after common_context because it can refer members to those
      bt_set_conditionally(@assigns_automatic_event_class_id) do |v|
        pr "bt_stream_class_set_assigns_automatic_event_class_id(#{variable}, #{v});"
      end

      @event_classes.each_with_index do |ec, i|
        var_name = "#{variable}_ec_#{i}"
        scope do
          pr "bt_event_class *#{var_name};"
          ec.get_declarator(trace_class: trace_class, variable: var_name, stream_class: variable)
          pr "bt_event_class_put_ref(#{var_name});"
        end
      end

      bt_set_conditionally(@assigns_automatic_stream_id) do |v|
        pr "bt_stream_class_set_assigns_automatic_stream_id(#{variable}, #{v});"
      end

      pr "bt_stream_class_put_ref(#{variable});"
    end

    # The getters code generated from event_common_context_field_class does not include
    # the event variable name used by the getters. As we do not know the variable
    # name that should be generated, we can not put it directly in the template,
    # since, if the code generation generates another name we must update the
    # template in addition.
    def get_getter(event:, arg_variables:)
      return unless event_common_context_field_class

      field = "#{event}_cc_f"
      scope do
        pr "const bt_field *#{field} = bt_event_borrow_common_context_field_const(#{event});"
        event_common_context_field_class.get_getter(variable: field, arg_variables: arg_variables)
      end
    end
  end

  class BTEventClass
    include BTPrinter
    include BTLocator
    include BTMatch
    extend BTFromH

    BT_MATCH_ATTRS = %i[parent name specific_context_field_class payload_field_class]

    attr_reader :name, :specific_context_field_class, :payload_field_class, :set_id, :domain, :register

    def initialize(parent:, name: nil, specific_context_field_class: nil, payload_field_class: nil, id: nil,
                   set_id: nil, domain: nil, register: true)

      @set_id = set_id
      @domain = domain
      @register = register

      @parent = parent
      @name = name
      raise 'Name is mandatory for BTEventClass' if name.nil? && !rec_trace_class.match

      if specific_context_field_class
        @specific_context_field_class = BTFieldClass.from_h(self,
                                                            specific_context_field_class)
      end
      @payload_field_class = BTFieldClass.from_h(self, payload_field_class) if payload_field_class

      @id = id
    end

    def get_declarator(trace_class:, variable:, stream_class:)
      # Store the variable name for introspection purposes (PATH)
      @variable = variable
      if @id
        pr "#{variable} = bt_event_class_create_with_id(#{stream_class}, #{@id});"
      else
        pr "#{variable} = bt_event_class_create(#{stream_class});"
      end

      pr "bt_event_class_set_name(#{variable}, \"#{@name}\");" if @name

      if @specific_context_field_class
        var_name = "#{variable}_sc_fc"
        scope do
          pr "bt_field_class *#{var_name};"
          @specific_context_field_class.get_declarator(trace_class: trace_class, variable: var_name)
          pr "bt_event_class_set_specific_context_field_class(#{variable}, #{var_name});"
          pr "bt_field_class_put_ref(#{var_name});"
        end
      end

      return unless @payload_field_class

      var_name = "#{variable}_p_fc"
      scope do
        pr "bt_field_class *#{var_name};"
        @payload_field_class.get_declarator(trace_class: trace_class, variable: var_name)
        pr "bt_event_class_set_payload_field_class(#{variable}, #{var_name});"
        pr "bt_field_class_put_ref(#{var_name});"
      end
    end

    def get_setter(event:, arg_variables:)
      if rec_stream_class.event_common_context_field_class
        field = "#{event}_cc_f"
        scope do
          pr "bt_field *#{field} = bt_event_borrow_common_context_field(#{event});"
          rec_stream_class.event_common_context_field_class.get_setter(variable: field, arg_variables: arg_variables)
        end
      end

      if @specific_context_field_class
        field = "#{event}_sc_f"
        scope do
          pr "bt_field *#{field} = bt_event_borrow_specific_context_field(#{event});"
          @specific_context_field_class.get_setter(variable: field, arg_variables: arg_variables)
        end
      end

      return unless @payload_field_class

      field = "#{event}_p_f"
      scope do
        pr "bt_field *#{field} = bt_event_borrow_payload_field(#{event});"
        @payload_field_class.get_setter(variable: field, arg_variables: arg_variables)
      end
    end

    def get_getter(event:, arg_variables:)
      if rec_trace_class.environment
        trace = 'trace'
        scope do
          pr "const bt_stream *stream = bt_event_borrow_stream_const(#{event});"
          pr "const bt_trace *#{trace} = bt_stream_borrow_trace_const(stream);"
          rec_trace_class.environment.get_getter(trace: trace, arg_variables: arg_variables)
        end
      end

      if rec_stream_class.event_common_context_field_class
        field = "#{event}_cc_f"
        scope do
          pr "const bt_field *#{field} = bt_event_borrow_common_context_field_const(#{event});"
          rec_stream_class.event_common_context_field_class.get_getter(variable: field, arg_variables: arg_variables)
        end
      end

      if @specific_context_field_class
        field = "#{event}_sc_f"
        scope do
          pr "const bt_field *#{field} = bt_event_borrow_specific_context_field_const(#{event});"
          @specific_context_field_class.get_getter(variable: field, arg_variables: arg_variables)
        end
      end

      return unless @payload_field_class

      field = "#{event}_p_f"
      scope do
        pr "const bt_field *#{field} = bt_event_borrow_payload_field_const(#{event});"
        @payload_field_class.get_getter(variable: field, arg_variables: arg_variables)
      end
    end
  end

  class BTFieldClass
    include BTLocator
    include BTPrinter
    include BTMatch
    using HashRefinements

    BT_MATCH_ATTRS = %i[type cast_type cast_type_is_struct]

    attr_accessor :cast_type_is_struct, :cast_type, :type

    def initialize(parent:)
      @parent = parent
    end

    def self.from_h(parent, model)
      key = model.delete(:type)
      # /!\ Recursion
      is_match_model = parent.rec_trace_class.match

      raise "No type in #{model}" unless key || is_match_model

      h = {
        'bool' => BTFieldClass::Bool,
        'bit_array' => BTFieldClass::BitArray,
        'integer_unsigned' => BTFieldClass::Integer::Unsigned,
        'integer_signed' => BTFieldClass::Integer::Signed,
        'single' => BTFieldClass::Real::SinglePrecision,
        'double' => BTFieldClass::Real::DoublePrecision,
        'enumeration_unsigned' => BTFieldClass::Enumeration::Unsigned,
        'enumeration_signed' => BTFieldClass::Enumeration::Signed,
        'string' => BTFieldClass::String,
        'array_static' => BTFieldClass::Array::Static,
        'array_dynamic' => BTFieldClass::Array::Dynamic,
        'structure' => BTFieldClass::Structure,
        'option_without_selector_field' => BTFieldClass::Option::WithoutSelectorField,
        'option_with_selector_field_bool' => BTFieldClass::Option::WithSelectorField::Bool,
        'option_with_selector_field_unsigned' => BTFieldClass::Option::WithSelectorField::IntegerUnsigned,
        'option_with_selector_field_signed' => BTFieldClass::Option::WithSelectorField::IntegerSigned,
        'variant' => BTFieldClass::Variant,
      }.freeze

      raise "No #{key} in FIELD_CLASS_NAME_MAP" unless h.include?(key) || is_match_model

      cast_type = model.delete(:cast_type)
      cast_type_is_struct = model.delete(:cast_type_is_struct)

      fc = h.include?(key) ? h[key].from_h(parent, model) : BTFieldClass::Default.new(parent: parent)

      # Since key (:type) can be a string or a regex, we store
      # the type into the field to apply string.match?(regex)
      # in place of comparing field objects.
      fc.type = key
      fc.cast_type = cast_type if cast_type
      fc.cast_type_is_struct = cast_type_is_struct if cast_type_is_struct
      fc
    end

    def get_declarator(*args, **dict)
      raise NotImplementedError, self.class
    end

    def bt_get_variable(arg_variables, is_array: false)
      internal = arg_variables.fetch('internal', [])
      return internal.shift unless internal.empty?

      type =
        if is_array
          "#{element_field_class.class.instance_variable_get(:@bt_type)}*"
        else
          self.class.instance_variable_get(:@bt_type)
        end
      var = GeneratedArg.new(@cast_type || type, rec_menber_class.name)

      arg_variables.fetch_append('outputs_allocated', var) if is_array
      arg_variables.fetch_append('outputs', var)
    end

    def get_getter(field:, arg_variables:)
      bt_func_get = self.class.instance_variable_get(:@bt_func) % 'get'
      variable = bt_get_variable(arg_variables).name
      cast_func = @cast_type ? "(#{@cast_type})" : ''
      pr "#{variable} = #{cast_func}#{bt_func_get}(#{field});"
    end

    def get_setter(field:, arg_variables:)
      bt_func_get = self.class.instance_variable_get(:@bt_func) % 'set'
      variable = bt_get_variable(arg_variables).name
      # We always explicitly cast to the proper bebeltrace type when sending messsages.
      pr "#{bt_func_get}(#{field}, (#{self.class.instance_variable_get(:@bt_type)})#{variable});"
    end
  end

  class BTFieldClass::Default < BTFieldClass
    extend BTFromH
  end

  class BTFieldClass::Bool < BTFieldClass
    extend BTFromH

    @bt_type = 'bt_bool'
    @bt_func = 'bt_field_bool_%s_value'

    def get_declarator(trace_class:, variable:)
      pr "#{variable} = bt_field_class_bool_create(#{trace_class});"
    end
  end

  class BTFieldClass::BitArray < BTFieldClass
    extend BTFromH
    attr_reader :length

    @bt_type = 'uint64_t'
    @bt_func = 'bt_field_bit_array_%s_value_as_integer'

    def initialize(parent:, length:)
      @parent = parent
      @length = length
    end

    def get_declarator(trace_class:, variable:)
      pr "#{variable} = bt_field_class_bit_array_create(#{trace_class}, #{@length});"
    end
  end

  class BTFieldClass::Integer < BTFieldClass
    attr_reader :field_value_range, :preferred_display_base

    def initialize(parent:, field_value_range: nil, preferred_display_base: nil)
      @parent = parent
      @field_value_range = field_value_range
      @preferred_display_base = preferred_display_base
    end

    def get_declarator(variable:)
      pr "bt_field_class_integer_set_field_value_range(#{variable}, #{@field_value_range});" if @field_value_range
      return unless @preferred_display_base

      pr "bt_field_class_integer_set_preferred_display_base(#{variable}, #{@preferred_display_base});"
    end
  end

  class BTFieldClass::Integer::Unsigned < BTFieldClass::Integer
    extend BTFromH

    @bt_type = 'uint64_t'
    @bt_func = 'bt_field_integer_unsigned_%s_value'

    def get_declarator(trace_class:, variable:)
      pr "#{variable} = bt_field_class_integer_unsigned_create(#{trace_class});"
      super(variable: variable)
    end
  end

  class BTFieldClass::Integer::Signed < BTFieldClass::Integer
    extend BTFromH

    @bt_type = 'int64_t'
    @bt_func = 'bt_field_integer_signed_%s_value'

    def get_declarator(trace_class:, variable:)
      pr "#{variable} = bt_field_class_integer_signed_create(#{trace_class});"
      super(variable: variable)
    end
  end

  class BTFieldClass::Real < BTFieldClass
  end

  class BTFieldClass::Real::SinglePrecision < BTFieldClass::Real
    extend BTFromH

    @bt_type = 'float'
    @bt_func = 'bt_field_real_single_precision_%s_value'

    def get_declarator(trace_class:, variable:)
      pr "#{variable} = bt_field_class_real_single_precision_create(#{trace_class});"
    end
  end

  class BTFieldClass::Real::DoublePrecision < BTFieldClass::Real
    extend BTFromH

    @bt_type = 'double'
    @bt_func = 'bt_field_real_double_precision_%s_value'

    def get_declarator(trace_class:, variable:)
      pr "#{variable} = bt_field_class_real_double_precision_create(#{trace_class});"
    end
  end

  module BTFieldClass::Enumeration
    class BTFieldClass::Enumeration::Mapping
      extend BTFromH
      include BTUtils
      include BTPrinter

      def initialize(parent:, label:, integer_range_set:)
        @parent = parent
        @label = label
        # Form [ [lower,upper], ...]
        @ranges = integer_range_set
      end

      def get_declarator(field_class:)
        bt_type_internal = self.class.instance_variable_get(:@bt_type_internal)
        scope do
          pr "bt_integer_range_set_#{bt_type_internal} *#{field_class}_range;"
          pr "#{field_class}_range = bt_integer_range_set_#{bt_type_internal}_create();"
          @ranges.each do |l, u|
            pr "bt_integer_range_set_#{bt_type_internal}_add_range(#{field_class}_range, #{l}, #{u});"
          end
          pr "bt_field_class_enumeration_#{bt_type_internal}_add_mapping(#{field_class}, \"#{@label}\", #{field_class}_range);"
          pr "bt_integer_range_set_#{bt_type_internal}_put_ref(#{field_class}_range);"
        end
      end
    end

    def initialize(parent:, mappings:)
      @parent = parent
      @mappings = mappings.map do |mapping|
        # Handle inheritence
        self.class.const_get('Mapping').from_h(self, mapping)
      end
    end

    def get_declarator(trace_class:, variable:)
      bt_type_internal = self.class.instance_variable_get(:@bt_type_internal)
      pr "#{variable} = bt_field_class_enumeration_#{bt_type_internal}_create(#{trace_class});"
      @mappings.each do |mapping|
        mapping.get_declarator(field_class: variable)
      end
    end
  end

  class BTFieldClass::Enumeration::Unsigned < BTFieldClass::Integer::Unsigned
    include BTFieldClass::Enumeration
    class BTFieldClass::Enumeration::Unsigned::Mapping < BTFieldClass::Enumeration::Mapping
      @bt_type_internal = 'unsigned'
    end

    @bt_type = 'uint64_t'
    @bt_type_internal = 'unsigned'
    @bt_func = 'bt_field_integer_unsigned_%s_value'
  end

  class BTFieldClass::Enumeration::Signed < BTFieldClass::Integer::Signed
    include BTFieldClass::Enumeration
    class BTFieldClass::Enumeration::Signed::Mapping < BTFieldClass::Enumeration::Mapping
      @bt_type_internal = 'signed'
    end

    @bt_type = 'int64_t'
    @bt_type_internal = 'signed'
    @bt_func = 'bt_field_integer_signed_%s_value'
  end

  class BTFieldClass::String < BTFieldClass
    extend BTFromH
    include BTUtils

    @bt_type = 'const char*'
    @bt_func = 'bt_field_string_%s_value'

    def get_declarator(trace_class:, variable:)
      pr "#{variable} = bt_field_class_string_create(#{trace_class});"
    end

    def get_getter(field:, arg_variables:)
      return super(field: field, arg_variables: arg_variables) unless @cast_type_is_struct

      bt_func_get = self.class.instance_variable_get(:@bt_func) % 'get'
      variable = bt_get_variable(arg_variables).name

      pr '// Dump string data to the struct.'
      pr "memcpy(&#{variable}, #{bt_func_get}(#{field}), sizeof(#{variable}));"
    end

    def get_setter(field:, arg_variables:)
      return super(field: field, arg_variables: arg_variables) unless @cast_type_is_struct

      variable = bt_get_variable(arg_variables).name

      pr '// Dump data to a temporal string.'
      pr "char *#{field}_temp = (char *)malloc(sizeof(#{variable}));"
      pr "assert(#{field}_temp != NULL && \"Out of memory\");"
      pr "memcpy(#{field}_temp, &#{variable}, sizeof(#{variable}));"
      pr ''
      pr '// Set string field with dumped data.'
      pr "bt_field_string_clear(#{field});"
      pr "bt_field_string_append_status #{field}_status = bt_field_string_append_with_length(#{field}, #{field}_temp, sizeof(#{variable}));"
      pr "assert(#{field}_status == BT_FIELD_STRING_APPEND_STATUS_OK && \"Out of memory\");"
      pr "free(#{field}_temp);"
    end
  end

  class BTFieldClass::Array < BTFieldClass
    attr_reader :element_field_class

    def initialize(parent:, element_field_class:)
      @parent = parent
      @element_field_class = BTFieldClass.from_h(self, element_field_class)
    end
  end

  class BTFieldClass::Array::Static < BTFieldClass::Array
    extend BTFromH
    using HashRefinements
    attr_reader :length

    def initialize(parent:, element_field_class:, length:)
      @length = length
      super(parent: parent, element_field_class: element_field_class)
    end

    def get_declarator(trace_class:, variable:)
      element_field_class_variable = "#{variable}_field_class"
      scope do
        pr "bt_field_class *#{element_field_class_variable};"
        @element_field_class.get_declarator(trace_class: trace_class, variable: element_field_class_variable)
        pr "#{variable} = bt_field_class_array_static_create(#{trace_class}, #{element_field_class_variable}, #{@length});"
        pr "bt_field_class_put_ref(#{element_field_class_variable});"
      end
    end

    def get_setter(field:, arg_variables:)
      usr_var = bt_get_variable(arg_variables, is_array: true)
      pr "for(uint64_t _i=0; _i < #{@length} ; _i++)"
      scope do
        v = "#{field}_e"
        pr "bt_field* #{v} = bt_field_array_borrow_element_field_by_index(#{field}, _i);"
        arg_variables.fetch_append('internal', GeneratedArg.new('', "#{usr_var.name}[_i]"))
        @element_field_class.get_setter(field: v, arg_variables: arg_variables)
      end
    end

    def get_getter(field:, arg_variables:)
      length = @length
      usr_var = bt_get_variable(arg_variables, is_array: true)
      pr "#{usr_var.name} = (#{usr_var.type}) malloc(#{length} * sizeof(#{usr_var.name}));"
      pr "for(uint64_t _i=0; _i < #{length} ; _i++)"
      scope do
        v = "#{field}_e"
        pr "const bt_field* #{v} = bt_field_array_borrow_element_field_by_index_const(#{field}, _i);"
        arg_variables.fetch_append('internal', GeneratedArg.new('', "#{usr_var.name}[_i]"))
        @element_field_class.get_getter(field: v, arg_variables: arg_variables)
      end
    end
  end

  class BTFieldClass::Array::Dynamic < BTFieldClass::Array
    extend BTFromH
    module WithLengthField
      attr_reader :length_field_path
    end
    using HashRefinements

    def initialize(parent:, element_field_class:, length_field_path: nil)
      super(parent: parent, element_field_class: element_field_class)
      return unless length_field_path

      extend(WithLengthField)
      @length_field_path = length_field_path
    end

    def get_declarator(trace_class:, variable:)
      element_field_class_variable = "#{variable}_field_class"
      scope do
        pr "bt_field_class *#{element_field_class_variable};"
        @element_field_class.get_declarator(trace_class: trace_class, variable: element_field_class_variable)
        if @length_field_path
          element_field_class_variable_length = "#{element_field_class_variable}_length"
          pr "bt_field_class *#{element_field_class_variable_length};"
          scope do
            element_field_class_variable_length_sm = "#{element_field_class_variable_length}_sm"
            pr "bt_field_class_structure_member *#{element_field_class_variable_length_sm};"
            field_class, id = resolve_path(@length_field_path)
            id.scan(/(\w+)|(\d+)/).each do |name, index|
              # String
              if name
                pr "#{element_field_class_variable_length_sm} = bt_field_class_structure_borrow_member_by_name(#{field_class.variable}, \"#{name}\");"
              else
                pr "#{element_field_class_variable_length_sm} = bt_field_class_structure_borrow_member_by_index(#{field_class.variable}, #{index});"
              end
            end
            pr "#{element_field_class_variable_length} = bt_field_class_structure_member_borrow_field_class(#{element_field_class_variable_length_sm});"
          end
          pr "#{variable} = bt_field_class_array_dynamic_create(#{trace_class}, #{element_field_class_variable}, #{element_field_class_variable_length});"
          pr "bt_field_class_put_ref(#{element_field_class_variable});"
        else
          pr "#{variable} = bt_field_class_array_dynamic_create(#{trace_class}, #{element_field_class_variable}, NULL);"
        end
      end
    end

    def get_setter(field:, arg_variables:)
      field_class, id = resolve_path(@length_field_path)
      length_field = field_class[id]
      pr "bt_field_array_dynamic_set_length(#{field}, #{length_field.name});"
      usr_var = bt_get_variable(arg_variables, is_array: true)
      pr "for(uint64_t _i=0; _i < #{length_field.name} ; _i++)"
      scope do
        v = "#{field}_e"
        pr "bt_field* #{v} = bt_field_array_borrow_element_field_by_index(#{field}, _i);"
        arg_variables.fetch_append('internal', GeneratedArg.new('', "#{usr_var.name}[_i]"))
        @element_field_class.get_setter(field: v, arg_variables: arg_variables)
      end
    end

    def get_getter(field:, arg_variables:)
      length = "#{field}_length"
      pr "uint64_t #{length} = bt_field_array_get_length(#{field});"
      usr_var = bt_get_variable(arg_variables, is_array: true)
      pr "#{usr_var.name} = (#{usr_var.type}) malloc(#{length} * sizeof(#{usr_var.name}));"
      pr "for(uint64_t _i=0; _i < #{length} ; _i++)"
      scope do
        v = "#{field}_e"
        pr "const bt_field* #{v} = bt_field_array_borrow_element_field_by_index_const(#{field}, _i);"
        arg_variables.fetch_append('internal', GeneratedArg.new('', "#{usr_var.name}[_i]"))
        @element_field_class.get_getter(field: v, arg_variables: arg_variables)
      end
    end
  end

  class BTMemberClass
    include BTMatch
    include BTLocator

    BT_MATCH_ATTRS = %i[name field_class]

    attr_reader :parent, :name, :field_class

    def initialize(parent:, field_class: nil, name: nil)
      @parent = parent
      is_match_model = parent.rec_trace_class.match
      raise ArgumentError, 'missing keyword: :name' unless name || is_match_model
      raise ArgumentError, 'missing keyword: :field_class' unless field_class || is_match_model

      @name = name # Name can be nil in the matching callbacks
      @field_class = BTFieldClass.from_h(self, field_class || {})
    end

    def bt_get_variable
      @field_class.bt_get_variable({})
    end
  end

  class BTFieldClass::Structure < BTFieldClass
    include BTMatchMembers
    extend BTFromH

    attr_reader :members

    BT_MATCH_ATTRS = [:members]

    def initialize(parent:, members: [])
      @parent = parent
      @members = members.collect { |m| BTMemberClass.new(parent: self, **m) }
    end

    def [](index)
      case index
      when ::Integer
        @members[index]
      when ::String
        @members.find { |m| m.name == index }
      else
        raise("Unknow Type (#{index.class}) for index: #{index}")
      end
    end

    def get_declarator(trace_class:, variable:)
      @variable = variable
      pr "#{variable} = bt_field_class_structure_create(#{trace_class});"
      @members.each_with_index do |m, i|
        var_name = "#{variable}_m_#{i}"
        scope do
          pr "bt_field_class *#{var_name};"
          m.field_class.get_declarator(trace_class: trace_class, variable: var_name)
          pr "bt_field_class_structure_append_member(#{variable}, \"#{m.name}\", #{var_name});"
          pr "bt_field_class_put_ref(#{var_name});"
        end
      end
    end

    def get_setter(variable:, arg_variables:)
      @members.each_with_index do |m, i|
        field = "#{variable}_m_#{i}"
        scope do
          pr "bt_field *#{field} = bt_field_structure_borrow_member_field_by_index(#{variable}, #{i});"
          m.field_class.get_setter(field: field, arg_variables: arg_variables)
        end
      end
    end

    def get_getter(variable:, arg_variables:)
      @members.each_with_index do |m, i|
        field = "#{variable}_m_#{i}"
        scope do
          pr "const bt_field *#{field} = bt_field_structure_borrow_member_field_by_index_const(#{variable}, #{i});"
          m.field_class.get_getter(field: field, arg_variables: arg_variables)
        end
      end
    end
  end

  class BTFieldClass::Option < BTFieldClass
    attr_reader :field_class

    def initialize(parent:, field_class:)
      @parent = parent
      @field_class = BTFieldClass.from_h(self, field_class)
    end
  end
  BTFieldClassOption = BTFieldClass::Option

  class BTFieldClass::Option::WithoutSelectorField < BTFieldClass::Option
    extend BTFromH
  end

  class BTFieldClass::Option::WithSelectorField < BTFieldClass::Option
    attr_reader :selector_field_path

    def initialize(parent:, field_class:, selector_field_path:)
      @selector_field_path = selector_field_path
      super(parent: parent, field_class: field_class)
    end
  end

  class BTFieldClass::Option::WithSelectorField::Bool < BTFieldClass::Option::WithSelectorField
    extend BTFromH
    attr_reader :selector_is_reversed

    def initialize(parent:, field_class:, selector_field_path:, selector_is_reversed: nil)
      @selector_is_reversed = selector_is_reversed
      super(parent: parent, field_class: field_class, selector_field_path: selector_field_path)
    end
  end

  class BTFieldClass::Option::WithSelectorField::IntegerUnsigned < BTFieldClass::Option::WithSelectorField
    extend BTFromH
    attr_reader :selector_ranges

    def initialize(parent:, field_class:, selector_field_path:, selector_ranges:)
      @selector_ranges = selector_ranges
      super(parent: parent, field_class: field_class, selector_field_path: selector_field_path)
    end
  end

  class BTFieldClass::Option::WithSelectorField::IntegerSigned < BTFieldClass::Option::WithSelectorField
    extend BTFromH
    attr_reader :selector_ranges

    def initialize(parent:, field_class:, selector_field_path:, selector_ranges:)
      @selector_ranges = selector_ranges
      super(parent: parent, field_class: field_class, selector_field_path: selector_field_path)
    end
  end

  class BTFieldClass::Variant < BTFieldClass
    extend BTFromH
    attr_reader :options

    class Option
      attr_reader :name, :field_class

      def initialize(parent:, name:, field_class:)
        @parent = parent
        @name = name
        @field_class = BTFieldClass.from_h(self, field_class)
      end
    end

    module WithoutSelectorField
    end

    module WithSelectorField
      attr_reader :selector_field_class

      class Option < BTFieldClass::Variant::Option
        attr_reader :ranges

        def initialize(parent:, name:, field_class:, ranges:)
          @ranges = ranges
          super(parent: parent, name: name, field_class: field_class)
        end
      end
    end

    def initialize(parent:, options:, selector_field_class: nil)
      @parent = parent
      if selector_field_class
        extend(WithSelectorField)
        @selector_field_class = selector_field_class
        @options = options.collect do |o|
          BTFieldClass::Variant::WithSelectorField::Option.new(name: o[:name], field_class: o[:field_class],
                                                               range: o[:range])
        end
      else
        extend(WithoutSelectorField)
        @options = options.collect do |o|
          BTFieldClass::Variant::Option.new(name: o[:name], field_class: o[:field_class])
        end
      end
    end
  end

  class BTEnvironmentClass
    include BTPrinter
    include BTLocator
    include BTMatchMembers
    extend BTFromH
    attr_reader :parent, :entries

    BT_MATCH_ATTRS = [:entries]

    def initialize(parent:, entries: [])
      @parent = parent
      @entries = entries.map { |entry| BTEntryClass.from_h(self, entry) }
    end

    def get_getter(trace:, arg_variables:)
      scope do
        @entries.each do |entry|
          entry.get_getter(trace: trace, arg_variables: arg_variables)
        end
      end
    end
  end

  class BTEntryClass
    include BTPrinter
    include BTMatch
    using HashRefinements

    BT_MATCH_ATTRS = %i[name type]

    attr_accessor :name, :type

    def initialize(parent:, name:, type:)
      @parent = parent
      @name = name
      @type = type
    end

    def self.from_h(parent, model)
      type = model.fetch(:type, nil)
      is_match_model = parent.rec_trace_class.match

      raise "No type in #{model}" unless type || is_match_model

      h = { 'string' => BTEntryClass::String,
            'integer_signed' => BTEntryClass::IntegerSigned }.freeze

      raise "Type #{type} not supported" unless h.include?(type) || is_match_model

      h.include?(type) ? h[type].from_h(parent, model) : BTEntryClass::Default.from_h(parent, model)
    end

    def get_getter(trace:, arg_variables:)
      var_name = bt_get_variable(arg_variables).name
      pr "const bt_value *#{var_name}_value = bt_trace_borrow_environment_entry_value_by_name_const(#{trace}, \"#{var_name}\");"
      pr "#{var_name} = bt_value_#{@type}_get(#{var_name}_value);"
    end

    def get_setter(trace:, arg_variables:)
      var_name = bt_get_variable(arg_variables).name
      bt_type_set = self.class.instance_variable_get(:@bt_type_set)
      pr "bt_trace_set_environment_entry_#{bt_type_set}(#{trace}, \"#{var_name}\", #{var_name});"
    end

    def bt_get_variable(arg_variables = {})
      var = GeneratedArg.new(self.class.instance_variable_get(:@bt_type), @name)
      arg_variables.fetch_append('outputs', var)
    end
  end

  class BTEntryClass::Default < BTEntryClass
    extend BTFromH
  end

  class BTEntryClass::String < BTEntryClass
    extend BTFromH

    @bt_type = 'const char*'
    @bt_type_set = 'string'
  end

  class BTEntryClass::IntegerSigned < BTEntryClass
    extend BTFromH

    @bt_type = 'int64_t'
    # Sadly it's ` bt_trace_set_environment_entry_integer() ` and not ` bt_trace_set_environment_entry_integer_signed()`
    @bt_type_set = 'integer'
  end
end
