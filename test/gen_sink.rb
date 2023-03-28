require 'yaml'
require 'erb'
require_relative 'bt2_stream_classes_generator'

SINK_TEMPLATE = <<~TEXT
  #include "component.h"
  #include "dispatch.h"
  #include <stdio.h>

  struct data_s {
    <%- @eventclasses.each do |m| -%>
    <%- m.callbacks.each do |c| -%>
    <%= c.name %>_calls_count = 0;
    <%- end -%>
    <%- end -%>
  }

  typedef struct data_s data_t;

  void btx_initialize_usr_data(common_data_t *common_data, void **usr_data)
  {
    data_t *data = new data_t;
    *usr_data = data;
    
    <%- @eventclasses.each do |m| -%>
    data-><%= m.name %>_calls_count = 0;
    <%- end -%>
  }

  void btx_finalize_usr_data(common_data_t *common_data, void *usr_data)
  {
    data_t *data = (data_t *) usr_data;

    <%- @eventclasses.each do |m| -%>
    printf("<%= m.name %>: %d", data-><%= m.name %>_calls_count);
    <%- end -%>

    delete data;
  }

  <%- @eventclasses.each do |m| -%>
  <%- m.callbacks.each do |c| -%>
  <%= c.definition %>
  <%- end -%>
  <%- end -%>

  void btx_register_usr_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
    <%- @eventclasses.each do |c| -%>
    <%= c.btx_register_usr_callbacks %>
    <%- end -%>
  }

TEXT

class BTEventCallback
  attr_reader :name

  def initialize(parent,name)
    @parent = parent
    @name = name
  end

  def definition
    <<~TEXT
    static void #{@name}(
      common_data_t *common_data, void *usr_data,
      #{@parent.args.map { |arg| "#{arg.type} #{arg.name}"}.join(", ") })
    {
      data->#{@parent.name}_calls_count += 0;
    }
    TEXT
  end
end

class BTEvent
  attr_reader :name, :args, :callbacks

  def self.sanitize(name)
    name.gsub(/[^0-9A-Za-z\-]/, '_')
  end

  def initialize(name, args)
    @name = name
    @args = args
    @callbacks = []
    @callbacks_count = 0
  end

  def name_sanitized
    self.class.sanitize(@name)
  end

  def new_callback(name: nil)
    @callbacks << BTEventCallback.new(
      self, name ? self.class.sanitize(name) : "#{name_sanitized}_#{@callbacks_count}")
    @callbacks_count += 1
    @callbacks.last
  end

  def btx_register_usr_callbacks
    @callbacks.map { |c| "btx_register_callbacks_#{name_sanitized}(name_to_dispatcher, &#{c.name});" }.join("\n")
  end
end

class BTSink
  attr_reader :eventclasses
  @eventclasses = []

  def initialize(model_yaml_path,callbacks_per_event)
    # Get btx_model data structure.
    t = Babeltrace2Gen::BTTraceClass.from_h(nil, model_yaml_path)

    # Create BTEvent instances and callbacks
    @eventclasses = t.stream_classes.map { |s| s.event_classes }.flatten.map do |e|
      arg_variables = []
      body = Babeltrace2Gen.context(indent: 1) do
        e.get_getter(event: nil, arg_variables: arg_variables)
      end
      event = BTEvent.new(e.name, arg_variables)
      callbacks_per_event.times { event.new_callback() }
      event
    end
  end

  def render
    template = ERB.new(SINK_TEMPLATE, trim_mode: '-')
    template.result(binding)
  end
end

y = YAML.load_file(ARGV[0])
sink = BTSink.new(y,2)

puts sink.render