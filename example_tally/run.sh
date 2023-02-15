#!/bin/bash
# set -e 

ruby ../main.rb -u 1.stream_classes.yaml -t SINK -p metababel2
make -C SINK.xprof

babeltrace2 \
	--plugin-path=/soft/debuggers/thapi/0.11.2/lib:./SINK.xprof \
	--component=filter.ompinterval.interval \
	--component=filter.zeinterval.interval \
	--component=filter.cudainterval.interval \
	--component=filter.clinterval.interval \
	--component=sink.metababel2.xprof \
	/home/avivasmeza/aurelio
#/home/avivasmeza/lttng-traces/iprof-20230206-175657

cd SINK.xprof
rm -f component.h dispatch.{h,c,o} params.{h,c,o} xprof.{c,o,so} my_callbacks.o my_demangle.o
cd -

