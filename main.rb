require 'yaml'
require 'optparse'
require 'erb'

require './gen_babeltrace_base'

class String
  #https://apidock.com/rails/String/indent
  def indent(amount, indent_string = nil, indent_empty_lines = false)
    indent_string = indent_string || self[/^[ \t]/] || " "
    re = indent_empty_lines ? /^/ : /^(?!$)/
    gsub(re, indent_string * amount)
  end
end

Dispatcher = Struct.new(:name, :args, :body) do
  def name_sanitized
    name.gsub(/[^0-9A-Za-z\-]/, '_')
  end
end

def wrote_dispatchers(folder, component_name, hash_type, hash_name, t)
  event_name = "event"
  event_classes = t.stream_classes.map(&:event_classes).flatten
  dispatchers = event_classes.map { |e|
    arg_variables = []
    body = Babeltrace2Gen.context(indent: 1) {
      e.get_getter(event: event_name, arg_variables: arg_variables)
    }
    Dispatcher.new(e.name, arg_variables, body)
  }

  File.open(File.join(folder, "dispatch.h"), 'w') do |f|
    template = File.read(File.join(SRC_DIR, "template/dispatch.h.erb"))
    declaration = ERB.new(template, trim_mode: "<>").result(binding)
    f.write(declaration)
  end

  File.open(File.join(folder, "dispatch.c"), 'w') do |f|
    template = File.read(File.join(SRC_DIR, "template/dispatch.c.erb"))
    definition = ERB.new(template, trim_mode: "<>").result(binding)
    f.write(definition)
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-f", "--file PATH", "[Mandatory] Path to the bt2 yaml file.") do |p|
    options[:file] = p
  end

  opts.on("-c", "--component TYPE", "[Mandatory] Node within a trace processing graph.") do |p|
    options[:component] = p
  end

end.parse!

raise OptionParser::MissingArgument if options[:file].nil?
raise OptionParser::MissingArgument if options[:component].nil?

SRC_DIR = ENV['SRC_DIR'] || '.'
template = ""
if options[:component] == "SINK"
  template = File.read(File.join(SRC_DIR, "template/sink.c.erb"))
elsif options[:component] == "FILTER"
  template = File.read(File.join(SRC_DIR, "template/filter.c.erb"))
end

  # Need to be passed as arguments
  component_name = "xprof"
  plugin_name = "roger"

  hash_type = "name_to_dispatcher_t"
  hash_name = "name_to_dispatcher"

  folder = "#{options[:component]}.#{component_name}"
  Dir.mkdir(folder) unless File.exists?(folder)

  File.open(File.join(folder, "#{component_name}.c"), 'w') do |f|
    str = ERB.new(template, trim_mode: "<>").result(binding)
    f.write(str)
  end

  y = YAML::load_file(options[:file])
  t = Babeltrace2Gen::BTTraceClass.from_h(nil, y)
  wrote_dispatchers(folder, component_name, hash_type, hash_name, t)
