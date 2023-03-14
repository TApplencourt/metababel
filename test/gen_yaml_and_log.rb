require "erb"
require "securerandom"
require 'yaml'

# TODO: Need to know how to set the seed.
# Kernel.srand(1)

# Number of samples to be generated for every event_class.
SAMPLES = 8
# Number of common_fields to be geneared.
CFIELDS = 2
# Number of payload fields to be generated.
PFIELDS = 2
# Size in strings and randon numbers generated.
LENGTH = 20

# Values generators.

EVENT_CLASS_NAME_GEN = lambda do 
    @counter = @counter + 1
    "test:semicolon_#{@counter}"    
end 
STRING_VALUE_GEN = lambda { SecureRandom.base64(LENGTH) }
INTEGER_VALUE_GEN = lambda { SecureRandom.random_number(LENGTH) }
BOOLEAN_VALUE_GEN = lambda { [true,false].sample }

FIELD_TYPE_TO_VALUE = {
    "string" => STRING_VALUE_GEN,
    "integer_unsigned" => INTEGER_VALUE_GEN,
    "bool" => BOOLEAN_VALUE_GEN
}

def gen_integer_field
    @counter = 0
    def gen_integer_field_wrapped
        @counter = @counter + 1 
        {
            :name => "if_#{@counter}",
            :field_class => {
                :type => 'integer_unsigned',
                :field_value_range => 32,
                :cast_type =>  'int'
            }
        }
    end
end 

def gen_string_field
    @counter = 0
    def gen_string_field_wrapped
        @counter = @counter + 1
        {
            :name => "sf_#{@counter}",
            :field_class => {
                :type => 'string',
                :cast_type => 'const char*'
            }
        }
    end
end 

def gen_bool_field
    @counter  = 0
    def gen_bool_field_wrapped 
        @counter = @counter + 1
        {
            :name => "bf_#{@counter}",
            :field_class => {
                :type => 'bool',
                :cast_type => 'bt_bool'
            }
        }
    end
end

CFIELDS_DEF_GENS = [ gen_bool_field, gen_string_field, gen_integer_field ]
PFIELDS_DEF_GENS = [ gen_bool_field, gen_string_field, gen_integer_field ]

def gen_event_class
    {
        :name => EVENT_CLASS_NAME_GEN.call,
        :payload_field_class => {
            :type => 'structure',
            :members => PFIELDS.times.map { send PFIELDS_DEF_GENS.sample }
        }
    }
end


STREAM_CLASSES = {
    :stream_classes => [
        {
            :name => 'sc1',
            :event_common_context_field_class => {
                :type => "structure",
                :members => CFIELDS.times.map { send CFIELDS_DEF_GENS.sample }
            },
            :event_classes => PFIELDS.times.map { gen_event_class }
        }
    ]
}

File.open("test_stream_classes.yml", "w") do |file| 
    file.write(STREAM_CLASSES.to_yaml)
end

common_members = STREAM_CLASSES[:stream_classes][0][:event_common_context_field_class][:members]
event_classes = STREAM_CLASSES[:stream_classes][0][:event_classes]

data = []
SAMPLES.times do
    data += event_classes.map do | ec |
        ec_data = {}
        ec_data[:name] = ec[:name]
        ec_data[:common] = common_members.map do |member|
            "#{member[:name]} = #{ FIELD_TYPE_TO_VALUE[member[:field_class][:type]].call.inspect }"
        end.join(", ")

        ec_data[:payload] = ec[:payload_field_class][:members].map do |member| 
            "#{member[:name]} = #{ FIELD_TYPE_TO_VALUE[member[:field_class][:type]].call.inspect }" 
        end.join(", ")
        ec_data
    end
end

METABABEL_LOG_TEMPLATE =  <<-TEXT
<%- data.each do | entry | -%>
<%= entry[:name] %>: { <%= entry[:common] %> }, { <%= entry[:payload] %> } 
<%- end -%>
TEXT

renderer = ERB.new(METABABEL_LOG_TEMPLATE, nil, '-')
output = renderer.result(binding)
File.write("test_babeltrace_output.txt", output, mode: "w")
