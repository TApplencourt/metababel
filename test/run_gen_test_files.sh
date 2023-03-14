#!/bin/bash -x

set -e

# Generates 'test_babeltrace_output.txt' and 'test_stream_classes.yaml'
ruby gen_yaml_and_log.rb
ruby gen_source.rb -t log -i test_babeltrace_output.txt -o test_callbacks_1.c
ruby gen_source.rb -t yaml -i ../display/3.interval_instances.yaml -o test_callbacks_2.c