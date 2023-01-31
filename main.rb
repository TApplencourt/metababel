require 'yaml'
require 'optparse'
require 'erb'
require_relative 'bt2_stream_classes_generator'
require_relative 'bt2_values_generator'

EventInfo = Struct.new(:name, :args, :body, :index_stream_class, :index_event_class) do
  def name_sanitized
    name.gsub(/[^0-9A-Za-z\-]/, '_')
  end
end

def erb_render_and_save(vars,
                        basename, out_folder, out_name = nil)
  template = File.read(File.join(__dir__, "template/#{basename}.erb"))
  # We need to trim line who contain only with space, because we indent our erb block <% %>
  # The trim_mode remove line only when it's start with the erb block
  # The regex remove the lines who are not indented
  # Maybe related to `https://github.com/ruby/erb/issues/24`
  str = ERB.new(template, trim_mode: '<>').result_with_hash(vars).gsub(/^ +$\n/, '')
  File.open(File.join(out_folder, out_name || basename), 'w') do |f|
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

# We preprent an empty new line from the body as a hack, to correct the indentation
# Indeeed the <%= body %> will be indented, but we don't don't want it,
# in the body string is already indented
# But we clean the white space empty line afterward \o/
def wrote_dispatchers(folder, t)
  event_name = 'event'
  dispatchers = t.map_event_classes_with_index do |e, index_stream_class, index_event_class|
    arg_variables = []
    body = Babeltrace2Gen.context(indent: 1) do
      e.get_getter(event: event_name, arg_variables: arg_variables)
    end
    EventInfo.new(e.name, arg_variables, "\n" + body, index_stream_class, index_event_class)
  end

  d = { dispatchers: dispatchers,
        event_name: event_name }

  erb_render_and_save(d, 'dispatch.h', folder)
  erb_render_and_save(d, 'dispatch.c', folder)
end

def wrote_creates(folder, t)
  event_name = 'event'
  downstream_events = t.map_event_classes_with_index do |e, index_stream_class, index_event_class|
    arg_variables = []
    body = Babeltrace2Gen.context(indent: 1) do
      e.get_setter(event: event_name, arg_variables: arg_variables)
    end
    EventInfo.new(e.name, arg_variables, "\n" + body, index_stream_class, index_event_class)
  end

  body_declarator_classes = "\n" + Babeltrace2Gen.context(indent: 1) do
    t.get_declarator(variable: 'trace_class')
  end

  d = { body_declarator_classes: body_declarator_classes,
        downstream_events: downstream_events,
        stream_classes: t.stream_classes,
        event_name: event_name }

  erb_render_and_save(d, 'create.h', folder)
  erb_render_and_save(d, 'create.c', folder)
end

options = { plugin_name: 'metababel',
            component_name: 'xprof' }

OptionParser.new do |opts|
  opts.banner = 'Usage: example.rb [options]'

  opts.on('-t', '--component TYPE', '[Mandatory] Node within a trace processing graph.') do |p|
    options[:component_type] = p
  end

  opts.on('-u', '--upstream PATH', '[Mandatory] Path to the bt2 yaml file.') do |p|
    options[:upstream] = p
  end

  opts.on('-d', '--downstream PATH', '[Optional] Path to the bt2 yaml file.') do |p|
    options[:downstream] = p
  end

  opts.on('-p', '--plugin-name PATH', '[Optional] Name of the bt2 plugin created.') do |p|
    options[:plugin_name] = p
  end

  opts.on('-c', '--component-name PATH', '[Optional] Name of the bt2 componant created.') do |p|
    options[:component_name] = p
  end

  opts.on('--params PATH', '[Optional] Name of YAML params definition.') do |p|
    options[:params] = p
  end
end.parse!

raise OptionParser::MissingArgument if options[:component_type].nil?

folder = "#{options[:component_type]}.#{options[:component_name]}"
Dir.mkdir(folder) unless File.exist?(folder)

d = options.filter { |k, _v| %i[plugin_name component_name].include?(k) }

d[:params_declaration] = ""
d[:params_definition] = ""
if options.key?(:params)
  y = YAML.load_file(options[:params])
  c = Babeltrace2Gen::BTValueCLass.from_h(y)
  body = Babeltrace2Gen.context(indent: 1) do
    c.get("usr_params", "params")
  end
  d[:params_declaration] =  c.get_struct_definition("params")
  d[:params_definition] = body
end

erb_render_and_save(d, "#{options[:component_type].downcase}.c", folder, outputname = "#{options[:component_name]}.c")
erb_render_and_save(d, 'component.h', folder)
erb_render_and_save(d, 'params.c', folder)

if %w[SOURCE FILTER].include?(options[:component_type])
  raise "Missing downstream model" unless options[:downstream]
  y = YAML.load_file(options[:downstream])
  t = Babeltrace2Gen::BTTraceClass.from_h(nil, y)
  wrote_creates(folder, t)
end

if %w[FILTER SINK].include?(options[:component_type])
  raise "Missing upstream model" unless options[:upstream]
  y = YAML.load_file(options[:upstream])
  t = Babeltrace2Gen::BTTraceClass.from_h(nil, y)
  wrote_dispatchers(folder, t)
end
