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

def get_dispatchers(e, hash_type, hash_name, event_name: "event", indent: 0)
  arg_variables = []
  body = Babeltrace2Gen.context(indent: 1) {
    e.get_getter(event: event_name, arg_variables: arg_variables)
  }

  definition = <<EOS

static void
btx_dispatch_<%= e.name_sanitized %>(
  UT_array *callbacks,
  const bt_event *#{event_name}) {
<% arg_variables.each do |s| %>
  <%= s.type %> <%= s.name %>;
<% end %>
<%= body %>
  // Call all the callbacks who where registered
  int *p;
  for(p=(int*)utarray_front(callbacks);
      p!=NULL;
      p=(int*)utarray_next(callbacks, p)) {
    printf("%d\\n",*p);
  }

}

void
btx_register_callbacks_<%= e.name_sanitized %>(<%= hash_type %> **<%= hash_name %>, int i)
{
  // Look-up our dispatcher
  <%= hash_type %> *s = NULL;
  HASH_FIND_STR(*<%= hash_name %>, "<%= e.name %>", s);
  if (!s) {
    // We didn't find the dispatcher, so we need to r
    // Create
    s = (<%= hash_type %> *) malloc(sizeof(<%= hash_type %>));
    s-> name = "<%= e.name %>";
    s-> dispatcher = &btx_dispatch_<%= e.name_sanitized %>;
    utarray_new(s->callbacks, &ut_int_icd);
    // and Register
    HASH_ADD_KEYPTR(hh, *<%= hash_name %>, s->name, strlen(s->name), s);
  }
  utarray_push_back(s->callbacks, &i);
}

EOS

  { :register_func_signature => "void btx_register_callbacks_#{e.name_sanitized}(#{hash_type}  **#{hash_name}, int i)",
    :body => ERB.new(definition, trim_mode: "<>").result(binding).indent(Babeltrace2Gen::BTPrinter::INDENT_INCREMENT.size*indent),
  }
end

def wrote_dispatchers(component_name, hash_type, hash_name, t)
  functions = t.stream_classes.map { |s|
    s.event_classes.map { |e|
      get_dispatchers(e, hash_type, hash_name)
    }
  }.flatten


  declaration_template = <<EOS
#pragma once
#include "dispacher_t.h"
<% functions.each do |f| %>
<%= f[:register_func_signature] %>; 
<% end %>
EOS

  definition_template = <<EOS
#include <babeltrace2/babeltrace.h>
#include "uthash.h"
#include "utarray.h"
#include "dispacher_t.h"
#include <stdio.h>
<% functions.each do |f| %>
<%= f[:body] %>
<% end %>
EOS

  File.open("#{component_name}_dispatch.h", 'w') do |f|
    declaration = ERB.new(declaration_template, trim_mode: "<>").result(binding)
    f.write(declaration)
  end

  File.open("#{component_name}_dispatch.c", 'w') do |f|
    definition = ERB.new(definition_template, trim_mode: "<>").result(binding)
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
if options[:component] == "SINK"
  template = File.read(File.join(SRC_DIR, "template/sink.c.erb"))
  # Need to be passed as arguments
  component_name = "xprof"
  plugin_name = "sink"

  hash_type = "name_to_dispatcher_t"
  hash_name = "name_to_dispatcher"

  File.open("#{component_name}.c", 'w') do |f|
    str = ERB.new(template, trim_mode: "<>").result(binding)
    f.write(str)
  end

  y = YAML::load_file(options[:file])
  t = Babeltrace2Gen::BTTraceClass.from_h(nil, y)
  wrote_dispatchers(component_name, hash_type, hash_name, t)
end

