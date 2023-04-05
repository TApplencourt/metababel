#!/bin/bash -x

set -e

metababel='ruby -I../lib ../bin/metababel'

# SINK.{tally,print} params
display_compact=true

# Generate interval messages "interval_callbacks.c"
ruby ./source_callbacks_generator.rb 3.btx_instances.yaml SOURCE.interval/interval_callbacks.c

# Generate SOURCE.invertal component
$metababel ../main.rb -d 2.interval_definitions.yaml -t SOURCE -p sample -c interval
make -C SOURCE.interval
babeltrace2 --plugin-path=SOURCE.interval \
            --component=source.sample.interval \
            --component=sink.text.details 

# Genarate SINK.tally component
$metababel ../main.rb -u 2.interval_definitions.yaml -t SINK -p display --params 1.params.yaml -c tally
make -C SINK.tally
babeltrace2 --plugin-path=SOURCE.interval:SINK.tally  \
            --component=source.sample.interval \
            --component=sink.display.tally  \
            --params="display_compact=${display_compact}"  


# Genarate FILTER.aggreg component
$metababel ../main.rb -u 2.interval_definitions.yaml -d 4.aggreg_definitions.yaml -t FILTER -p tally_1 -c aggregation
make -C FILTER.aggregation
babeltrace2 --plugin-path=SOURCE.interval:FILTER.aggregation  \
            --component=source.sample.interval \
            --component=filter.tally_1.aggregation

# Genarate SINK.print component
$metababel ../main.rb -u 4.aggreg_definitions.yaml,2.interval_definitions.yaml -t SINK -p tally_2 --params 1.params.yaml -c print
make -C SINK.print
babeltrace2 --plugin-path=SOURCE.interval:FILTER.aggregation:SINK.print  \
            --component=source.sample.interval \
            --component=filter.tally_1.aggregation \
            --component=sink.tally_2.print

# Cleaning up
make -C SOURCE.interval clean
make -C SINK.tally clean 
make -C FILTER.aggregation clean
make -C SINK.print clean

