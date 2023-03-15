require "erb"
require "securerandom"
require 'yaml'
require 'optparse'

$options = {}
OptionParser.new do |opts|
    opts.banner = 'Usage: gen_yaml_and_log.rb [$options] <output_file_path>.{yaml,c}'

    # BTX MODEL GENERATION $options

    opts.on("-m", "--events N", Integer, 'Number of events to be generated, default: 1.') do |p|
        $options[:events] = p
    end

    opts.on('-e', '--event_prefix EVENT_NAME', String, 'Prefix for event names to be generated, default: "event_".') do |p|
        $options[:event_prefix] = p
    end

    opts.on("-c", "--rand_cfields N", Integer, 'Number of common_fields in stream_class, default: 1.') do |p|
        $options[:rand_cfields] = p
    end

    opts.on("-p", "--rand_pfields N", Integer, 'Number of payload_fields per event_class, default: 1.') do |p|
        $options[:rand_pfields] = p
    end

    opts.on('-k', '--fixed_cfields ARRAY', Array, 'Override --rand_cfields, default: "str,int32,int64,bool".') do |p|
        $options[:fixed_cfields] = p
    end

    opts.on('-j', '--fixed_fields ARRAY', Array, 'Override --rand_pfields, default: "str,int32,int64,bool".') do |p|
        $options[:fixed_fields] = p
    end
 
    opts.on('-l', '--length N', Integer, 'Length of strings and integers generated, default: 10') do |p|
        $options[:length] = p
    end

    # BTX INSTANCE GENERATION $options

    opts.on('-s', '--fixed_string_value STRING', String,'Non-random string value.') do |p|
        $options[:fixed_string_value] = p
    end

    opts.on('-i', '--fixed_integer_value INT', Integer,'Non-random unsigned integer value.') do |p|
        $options[:fixed_integer_value] = p
    end

    opts.on('-b', '--fixed_boolean_value BOOL', TrueClass,'Non-random random boolean value.') do |p|
        $options[:fixed_boolean_value] = p
    end

    opts.on('-n', '--samples N', Integer, 'Number of instances per event class to be generated.') do |p|
        $options[:samples] = p
    end

    opts.on('-o', '--output NAME', String, 'Output filename prefix, default: "example".') do |p|
        $options[:output] = p
    end

    opts.on_tail("-h", "--help", "Prints this help") do
        puts opts
        exit
    end
end.parse!

# TODO: Need to know how to set the seed.
# Kernel.srand(1)

# Number of samples to be generated for every event_class.
N_SAMPLES = $options.fetch(:samples,1)
# Numbe of event classes
N_EVENTS = $options.fetch(:events,1)
# Number of common_fields to be geneared for every event class.
N_CFIELDS = $options.fetch(:rand_cfields,1)
# Number of payload fields to be generated for every event class.
N_PFIELDS = $options.fetch(:rand_pfields,1)
# Size in strings and randon numbers generated.
LENGTH = $options.fetch(:length,10)
# Output file name
OUTPUT_NAME = $options.fetch(:output,"example").strip

@counter = 0

##
# STREAM CLASSES YAML FILE GENERATION 

def gen_integer64_field
    # Need lazy evaluation to ensure every new call over this method
    # updates the counter number properly. This is required because 
    # This function is embeded into a hash FIELD_TYPES_TO_GENFUNC. 
    def gen_integer64_field_wrapped
        @counter = @counter + 1 
        {
            :name => "if_#{@counter}",
            :field_class => {
                :type => 'integer_unsigned',
                :field_value_range => 64,
                :cast_type =>  "int64_t"
            }
        }
    end 
end 

def gen_integer32_field
    def gen_integer32_field_wrapped
        @counter = @counter + 1 
        {
            :name => "if_#{@counter}",
            :field_class => {
                :type => 'integer_unsigned',
                :field_value_range => 32,
                :cast_type =>  "int32_t"
            }
        }
    end 
end 

def gen_string_field
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

FIELD_TYPES_TO_GENFUNC = {
    "string" => gen_string_field,
    "int64" => gen_integer64_field,
    "int32" => gen_integer32_field,
    "bool" => gen_bool_field
}

def gen_common_fields 
    if $options.has_key?(:fixed_cfields)
        return $options[:fixed_cfields].map { |tname| send FIELD_TYPES_TO_GENFUNC[tname] }
    end
    return N_CFIELDS.times.map { send FIELD_TYPES_TO_GENFUNC.values.sample }
end 

def gen_payload_fields
    if $options.has_key?(:fixed_pfields)
        return $options[:fixed_pfields].map { |tname| send FIELD_TYPES_TO_GENFUNC[tname] }
    end
    return N_PFIELDS.times.map { send FIELD_TYPES_TO_GENFUNC.values.sample }
end

def gen_event_class_name 
    @counter = @counter + 1
    $options.has_key?(:event_prefix) ? "#{$options[:event_prefix]}_#{@counter}" : "event_#{@counter}"    
end

def gen_event_class
    {
        :name => gen_event_class_name,
        :payload_field_class => {
            :type => 'structure',
            :members => gen_payload_fields
        }
    }
end

stream_classes = {
    :stream_classes => [ 
        { 
            :name => 'sc1',
            :event_common_context_field_class => {
                :type => "structure",
                :members => gen_common_fields
            },
            :event_classes => N_EVENTS.times.map { gen_event_class }
        }
    ]
}

File.open("btx_model_#{OUTPUT_NAME}.yml", "w") do |file| 
    file.write(stream_classes.to_yaml)
end

##
# EVENT INSTANCES GENERATION FOR BABELTRACE LOG

string_value_gen = $options.has_key?(:fixed_string_value) ? lambda { $options[:string_gen] } : lambda { SecureRandom.base64(LENGTH) }
integer_value_gen = $options.has_key?(:fixed_integer_value) ? lambda { $options[:integer_gen] } : lambda { SecureRandom.random_number(LENGTH) }
boolean_value_gen = $options.has_key?(:fixed_boolean_value) ? lambda { $options[:boolean_gen] } : lambda { [true,false].sample }

field_type_to_value = {
    "string" => string_value_gen,
    "integer_unsigned" => integer_value_gen,
    "bool" => boolean_value_gen
}

common_members = stream_classes[:stream_classes][0][:event_common_context_field_class][:members]
event_classes = stream_classes[:stream_classes][0][:event_classes]

data = []
N_SAMPLES.times do
    data += event_classes.map do | ec |
        ec_data = {}
        ec_data[:name] = ec[:name]
        ec_data[:common] = common_members.map do |member|
            "#{member[:name]} = #{ field_type_to_value[member[:field_class][:type]].call.inspect }"
        end.join(", ")

        ec_data[:payload] = ec[:payload_field_class][:members].map do |member| 
            "#{member[:name]} = #{ field_type_to_value[member[:field_class][:type]].call.inspect }" 
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
File.open("btx_log_#{OUTPUT_NAME}.txt", "w") do |file| 
    file.write(output)
end
