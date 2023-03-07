#!/bin/bash -x

set -e

# SINK.{tally,print} params
display_compact=true

# Generate interval messages "interval_callbacks.c"
ruby ./source_callbacks_generator.rb 3.interval_instances.yaml SOURCE.interval/interval_callbacks.c

# Generate SOURCE.invertal component
ruby ../main.rb -d 2.interval_definitions.yaml -t SOURCE -p sample -c interval
make -C SOURCE.interval
babeltrace2 --plugin-path=SOURCE.interval \
            --component=source.sample.interval \
            --component=sink.text.details 

# Genarate SINK.tally component
ruby ../main.rb -u 2.interval_definitions.yaml -t SINK -p display --params 1.params.yaml -c tally
make -C SINK.tally
babeltrace2 --plugin-path=SOURCE.interval:SINK.tally  \
            --component=source.sample.interval \
            --component=sink.display.tally  \
            --params="display_compact=${display_compact}"  


# Genarate FILTER.aggreg component
ruby ../main.rb -u 2.interval_definitions.yaml -d 4.aggreg_definitions.yaml -t FILTER -p by_backend --params 1.params.yaml -c aggreg
make -C FILTER.aggreg
babeltrace2 --plugin-path=SOURCE.interval:FILTER.aggreg  \
            --component=source.sample.interval \
            --component=filter.by_backend.aggreg

# Genarate SINK.print component
ruby ../main.rb -u 4.aggreg_definitions.yaml,2.interval_definitions.yaml -t SINK -p display --params 1.params.yaml -c print
make -C SINK.print
babeltrace2 --plugin-path=SOURCE.interval:FILTER.aggreg:SINK.print  \
            --component=source.sample.interval \
            --component=filter.by_backend.aggreg \
            --component=sink.display.print

# Cleaning up
make -C SOURCE.interval clean
make -C SINK.tally clean 
make -C FILTER.aggreg clean
make -C SINK.print clean

