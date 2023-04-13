require 'optparse'
require 'yaml'
require 'erb'

REGEXT_PRETTY = /
 =\s            # We are interested to the right of the equal sign
 (
    ""|         # Empty string
    ".*?[^\\]"| # String who can contain space and quoted string
    [^\s,]+     # Anything except space and comma
 )
/x

SOURCE_TEMPLATE = <<~TEXT
  /* Code generated by #{__FILE__} */

  #include <metababel/metababel.h>
  #include <stdbool.h>

  void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  }

  btx_source_status_t btx_push_usr_messages(void *btx_handle, void *usr_data) {
      <%- data.each do | entry | -%>
      <%- entry.fetch(:times,1).times do -%>
      btx_push_message_<%= entry[:name] %>(btx_handle, <%= entry[:field_values].join(",") %>);
      <%- end -%>
      <%- end -%>
      return BTX_SOURCE_END;
  }

TEXT

def sanitize_value(field_value, field_class)
  return field_value unless field_class

  case field_class[:type]
  when 'integer_signed'
    "INT64_C(#{field_value})"
  when 'integer_unsigned'
    "UINT64_C(#{field_value})"
  else
    field_value
  end
end

def get_field_classes(yaml)
  return yaml[:field_class] if yaml.key?(:field_class)

  yaml.values.flatten.filter_map { |d| get_field_classes(d) if d.is_a?(Hash) }.flatten
end

def parse_log(input_path, yaml_path = nil)
  field_classes = yaml_path ? get_field_classes(YAML.load_file(yaml_path)) : []

  File.open(input_path, 'r') do |file|
    file.each_line.map do |line|
      # Line format support checks
      match = line.match(REGEXT_PRETTY)
      raise "Unsupported format for '#{line}'." unless match

      i = line.index('{')
      head, _, tail = line.partition(': {')

      field_values =  tail.scan(REGEXT_PRETTY).flatten
      data = {
        name: head.gsub(/[^0-9A-Za-z-]/, '_'), # Should reuse metababel mangling
        field_values: field_values.zip(field_classes).map { |fvalue, fclass| sanitize_value(fvalue, fclass) }
      }
    end
  end
end

def render_and_save(data, output_path)
  renderer = ERB.new(SOURCE_TEMPLATE, trim_mode: '-')
  output = renderer.result(binding)
  File.write(output_path, output, mode: 'w')
end

DOCS = <<-DOCS
  Usage: #{$0}.rb [options]

  Example:
    ruby #{$0} -y stream_classes.yaml -i btx_log.txt -o callbacks.c
DOCS

# Display help if no arguments.
ARGV << '-h' if ARGV.empty?

options = {}

OptionParser.new do |opts|
  opts.banner = DOCS

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end

  opts.on('-y', '--yaml PATH', '[Mandatory] Path to btx_model.yaml.') do |p|
    options[:yaml_path] = p
  end

  opts.on('-i', '--log PATH', '[Mandatory] Path to btx_log.txt.') do |p|
    options[:input_path] = p
  end

  opts.on('-o', '--output PATH', '[Mandatory] Path to the bt2 SOURCE file.') do |p|
    options[:output_path] = p
  end
end.parse!

raise OptionParser::MissingArgument if options[:output_path].nil?

data = options.key?(:input_path) ? parse_log(options[:input_path], options[:yaml_path]) : []
render_and_save(data, options[:output_path])
