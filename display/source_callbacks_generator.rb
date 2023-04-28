require 'yaml'
require 'erb'

DOCS = <<-DOCS
Command usage: ruby source_callbacks_generator.rb <callbacks_instance.yaml> <callbacks_source_file.c>

    Generates SOURCE component callbacks to push messages downtream as defined in the callbacks_instance.yaml

    Example: 
        ruby source_callbacks_generator.rb ./3.interval_instances.yaml ./SOURCE.interval/interval_callbacks.c

DOCS

# Testing minimun arguments requirement
if ARGV.count != 2 then 
    puts DOCS
    return
end

test_file_path = ARGV[0]
out_file_path = ARGV[1]

data = YAML.load_file(test_file_path)

template =  <<-TEXT
/* Code generaed by source_callbacks_generator.rb */

#include <metababel/metababel.h>

void btx_push_usr_messages(void *btx_handle, void *usr_data, btx_source_status_t *status) {

  <%- data.each do | entry | -%>
  <%- entry.fetch(:times,1).times do -%>
  btx_push_message_<%= entry[:name].gsub(":","_") %>(btx_handle,<%=  entry[:field_values].map(&:inspect).join(",") %>);
  <%- end -%>
  <%- end -%>

  *status = BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}

TEXT

renderer = ERB.new(template, nil, '-')
output = renderer.result()
File.write(out_file_path, output, mode: "w")