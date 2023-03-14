require 'optparse'
require 'yaml'
require 'erb'


REGEXT_PRETTY = %r{
 =\s            # We are interested to the right of the equal sign
 (
    ""|         # Empty string
    ".*?[^\\]"| # String who can contain space and quoted string
    [^\s,]+     # Anything except space and comma
 )
}x

SOURCE_TEMPLATE =  <<-TEXT
/* Code generaed by source_callbacks_generator.rb */

#include "component.h"
#include "create.h"

void btx_push_usr_messages(struct common_data_s *common_data) {

    <%- data.each do | entry | -%>
    <%- entry.fetch(:times,1).times do -%>
    btx_push_message_<%= entry[:name].gsub(":","_") %>(common_data,<%=  entry[:field_values].join(",") %>);
    <%- end -%>
    <%- end -%>
}

TEXT

def parse_log(input_path)
  data_list = []
  File.open(input_path, "r") do |f|
    f.each_line do |line|

      # Line format support checks
      match = line.match(REGEXT_PRETTY)
      raise "Unsupported format for '#{line}'." unless match

      i = line.index('{')
      head, _, tail = line.partition(": {")
      
      data = {}
      data[:name]=head.gsub(/[^0-9A-Za-z\-]/, '_') # Should reuse metababel mangling
      data[:field_values] = tail.scan(REGEXT_PRETTY).flatten
      data_list.append(data)
    end
  end
  data_list
end

def parse_yaml(input_path)
  data = YAML.load_file(input_path)
  data.each do |item| 
    item[:field_values] = item[:field_values].map(&:inspect)
  end 
end 

def render_and_save(data, output_path) 
  renderer = ERB.new(SOURCE_TEMPLATE, nil, '-')
  output = renderer.result(binding)
  File.write(output_path, output, mode: "w")
end

DOCS = <<-DOCS
  Usage: example.rb [options]  
  
  Example: 
    ruby example.rb -t yaml -i stream_classes.yaml -o callbacks.c
    ruby example.rb -t log -f EE -i babeltrace.log -o  callbacks.c
DOCS

options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: example.rb [options]'

  opts.on("-h", "--help", "Prints this help") do
      puts DOCS
      exit
  end

  opts.on('-t', '--type TYPE', "[Mandatory] 'yaml|log'.") do |p|
    options[:input_type] = p
  end

  opts.on('-i', '--input PATH', '[Mandatory] Path to the bt2 yaml file.') do |p|
    options[:input_path] = p
  end

  opts.on('-o', '--output PATH', '[Optional] Path to the bt2 SOURCE file.') do |p|
    options[:output_path] = p
  end

end.parse!

raise OptionParser::MissingArgument if options[:input_type].nil?
raise OptionParser::MissingArgument if options[:input_path].nil?
raise OptionParser::MissingArgument if options[:output_path].nil?

case options[:input_type]
when "yaml"
  render_and_save(
    parse_yaml(options[:input_path]), 
    options[:output_path])
when "log"
  render_and_save( 
    parse_log(options[:input_path]), 
    options[:output_path])
else
  "Error: unknown argument for --type (-t) #{options[:input_type]}"
end