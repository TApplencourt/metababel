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
working_path = File.expand_path(File.dirname(__FILE__))

data = YAML.load_file(test_file_path)
entries = data[:entries]

template =  <<-TEXT
#include "component.h"
#include "create.h"
#include <stdio.h>

void btx_push_usr_messages(struct common_data_s *common_data) {

    params_t *params = (params_t*) malloc(sizeof(params_t));
    btx_read_params(common_data, params);
    printf("PARAM DISPLAY: %s\\n", params->display);
    free(params);

    <%- entries.each do | entry | -%>
    <%- entry[:samples].each do | sample | -%>
    <%- sample[:times].times do -%>
    btx_push_message_<%= entry[:name].gsub(":","_") %>(common_data,<%= sample[:values].join(",") %>);
    <%- end -%>
    <%- end -%>
    <%- end -%>
}

TEXT

renderer = ERB.new(template, nil, '-')
output = renderer.result()
File.write(out_file_path, output, mode: "w")