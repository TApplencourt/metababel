require 'yaml'
require 'optparse'
require 'erb'

require './gen_babeltrace_base'

class String
  # https://apidock.com/rails/String/indent
  def indent(amount, indent_string: nil, indent_empty_lines: false)
    indent_string = indent_string || self[/^[ \t]/] || ' '
    re = indent_empty_lines ? /^/ : /^(?!$)/
    gsub(re, indent_string * amount)
  end
end

EventInfo = Struct.new(:name, :args, :body, :index_stream_class, :index_event_class) do
  def name_sanitized
    name.gsub(/[^0-9A-Za-z\-]/, '_')
  end
end

def erb_render_and_save(basename, out_folder, b)
  template = File.read(File.join(SRC_DIR, "template/#{basename}.erb"))
  str = ERB.new(template, trim_mode: '<>').result(b)
  File.open(File.join(out_folder, basename), 'w') do |f|
    f.write(str)
  end
end

class Babeltrace2Gen::BTTraceClass
  def map_event_classes_with_index
    @stream_classes.map.with_index do |s, index_stream_class|
      s.event_classes.map.with_index do |e, index_event_class|
        yield(e, index_stream_class, index_event_class)
      end
    end.flatten
  end
end

def wrote_dispatchers(folder, component_name, hash_type, hash_name, t)
  event_name = 'event'
  begin
    dispatchers = t.map_event_classes_with_index do |e, index_stream_class, index_event_class|
      arg_variables = []
      body = Babeltrace2Gen.context(indent: 1) do
        e.get_getter(event: event_name, arg_variables: arg_variables)
      end
      EventInfo.new(e.name, arg_variables, body, index_stream_class, index_event_class)
    end

    erb_render_and_save('dispatch.h', folder, binding)
    erb_render_and_save('dispatch.c', folder, binding)
  end
end

def wrote_creates(folder, component_name, hash_type, hash_name, t)
  event_name = 'event'
  begin
    downstream_events = t.map_event_classes_with_index do |e, index_stream_class, index_event_class|
      arg_variables = []
      body = Babeltrace2Gen.context(indent: 1) do
        e.get_setter(event: event_name, arg_variables: arg_variables)
      end
      EventInfo.new(e.name, arg_variables, body, index_stream_class, index_event_class)
    end

    self_component = 'self_component'
    body_declarator_classes = Babeltrace2Gen.context(indent: 1) do
      t.get_declarator(variable: 'trace_class')
    end

    downstream_streams = t.stream_classes

    erb_render_and_save('create.h', folder, binding)
    erb_render_and_save('create.c', folder, binding)
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: example.rb [options]'

  opts.on('-c', '--component TYPE', '[Mandatory] Node within a trace processing graph.') do |p|
    options[:component] = p
  end

  opts.on('-u', '--upstream PATH', '[Mandatory] Path to the bt2 yaml file.') do |p|
    options[:upstream] = p
  end

  opts.on('-d', '--downstream PATH', '[Optional] Path to the bt2 yaml file.') do |p|
    options[:downstream] = p
  end

end.parse!

raise OptionParser::MissingArgument if options[:component].nil?

SRC_DIR = ENV['SRC_DIR'] || '.'
template = ''
if options[:component] == 'SINK'
  template = File.read(File.join(SRC_DIR, 'template/sink.c.erb'))
elsif options[:component] == 'FILTER'
  template = File.read(File.join(SRC_DIR, 'template/filter.c.erb'))
end

# Need to be passed as arguments
component_name = 'xprof'
plugin_name = 'roger'

hash_type = 'name_to_dispatcher_t'
hash_name = 'name_to_dispatcher'

folder = "#{options[:component]}.#{component_name}"
Dir.mkdir(folder) unless File.exist?(folder)

File.open(File.join(folder, "#{component_name}.c"), 'w') do |f|
  str = ERB.new(template, trim_mode: '<>').result(binding)
  f.write(str)
end

y = YAML.load_file(options[:upstream])
t = Babeltrace2Gen::BTTraceClass.from_h(nil, y)
wrote_dispatchers(folder, component_name, hash_type, hash_name, t)

if options[:component] == 'FILTER'
  y = YAML.load_file(options[:downstream])
  t = Babeltrace2Gen::BTTraceClass.from_h(nil, y)
  wrote_creates(folder, component_name, hash_type, hash_name, t)
end
