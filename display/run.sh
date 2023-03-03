#!/bin/bash -x

set -e

# Cleaning up
make -C SOURCE.interval clean
make -C SINK.tally clean 
make -C FILTER.tally clean
make -C SINK.print clean

# SINK.tally params
display_compact=true

# Generate interval messages "interval_callbacks.c"
ruby ./source_callbacks_generator.rb 3.interval_instances.yaml SOURCE.interval/interval_callbacks.c

# Generate SOURCE.invertal component
ruby ../main.rb -d 2.interval_definitions.yaml -t SOURCE -p convert --params 1.params.yaml -c interval
make -C SOURCE.interval
# babeltrace2 --plugin-path=SOURCE.interval \
#             --component=source.convert.interval \
#             --component=sink.text.details 

# Genarate SINK.tally component
# ruby ../main.rb -u 2.interval_definitions.yaml -t SINK -p display --params 1.params.yaml -c tally
# make -C SINK.tally
# babeltrace2 --plugin-path=SOURCE.interval:SINK.tally  \
#             --component=source.convert.interval \
#             --component=sink.display.tally  \
#             --params="display_compact=${display_compact}"  

# Genarate FILTER.tally component
ruby ../main.rb -u 2.interval_definitions.yaml -d 4.tally_definitions.yaml -t FILTER -p aggregate --params 1.params.yaml -c tally
make -C FILTER.tally
# babeltrace2 --plugin-path=SOURCE.interval:FILTER.tally  \
#             --component=source.convert.interval \
#             --component=filter.aggregate.tally

# Genarate SINK.print component
ruby ../main.rb -u 5.tally_noninterval_definitions.yaml -t SINK -p display --params 1.params.yaml -c print
make -C SINK.print
babeltrace2 --plugin-path=SOURCE.interval:FILTER.tally:SINK.print  \
            --component=source.convert.interval \
            --component=filter.aggregate.tally \
            --component=sink.display.print

# Cleaning up
make -C SOURCE.interval clean
make -C SINK.tally clean 
make -C FILTER.tally clean
make -C SINK.print clean

