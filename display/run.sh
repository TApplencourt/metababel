#!/bin/bash
set -e 

# export LIBBABELTRACE2_INIT_LOG_LEVEL=DEBUG
# export BABELTRACE_CLI_LOG_LEVEL=DEBUG

cd SINK.tally
rm -f component.h dispatch.{h,c,o} params.{h,c,o} tally.{c,o,so} my_callbacks.o my_demangle.o
cd -

ruby ../main.rb -u interval.yaml -t SINK -p display -c tally
make -C SINK.tally

babeltrace2 \
	--plugin-path=/soft/debuggers/thapi/0.11.2/lib:./SINK.tally \
	--component=filter.ompinterval.interval \
	--component=filter.zeinterval.interval \
	--component=filter.cudainterval.interval \
	--component=filter.clinterval.interval \
	--component=sink.display.tally \
	/home/avivasmeza/aurelio

cd SINK.tally
rm -f component.h dispatch.{h,c,o} params.{h,c,o} tally.{c,o,so} my_callbacks.o my_demangle.o
cd -

