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
entries = data[:entries]

template =  <<-TEXT
/* Code generaed by source_callbacks_generator.rb */

#include "component.h"
#include "create.h"
#include <stdio.h>

void btx_push_usr_messages(struct common_data_s *common_data) {

    params_t *params = (params_t*) malloc(sizeof(params_t));
    btx_read_params(common_data, params);

    // NOTE: We need to be carefull, since if these params are not pased
    // by command line they will be initialized with undesirable values (unknown).
    // Maybe is more secure to provide a default value in the params.yaml
    printf("PRINTING PARAMS FROM SOURCE...\\n");
    printf("PARAM DISPLAY: %s\\n", params->display_compact ? "true" : "false");
    printf("PARAM DISPLAY: %s\\n", params->demangle_name ? "true" : "false");
    printf("PARAM DISPLAY: %s\\n", params->display_human ? "true" : "false");
    printf("PARAM DISPLAY: %s\\n", params->display_metadata ? "true" : "false");
    printf("PARAM DISPLAY: %lu\\n", params->display_name_max_size);
    printf("PARAM DISPLAY: %s\\n", params->display_kernel_verbose ? "true" : "false");
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