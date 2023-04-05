#!/bin/bash -xe

ruby -I../lib ../bin/metababel -d 1.stream_classes.yaml -t SOURCE -p metababel1 --params 1.params.yaml 
make -C SOURCE.metababel1.btx/
babeltrace2 --plugin-path=SOURCE.metababel1.btx --component=source.metababel1.btx --params="display=tests2323" --component=sink.text.details 

#ruby -I../lib ../bin/metababel -u 1.stream_classes.yaml -t SINK -p metababel2
#make -C SINK.xprof
#babeltrace2  --plugin-path=SOURCE.xprof:SINK.xprof  --component=source.metababel1.xprof --component=sink.metababel2.xprof

#ruby -I../lib ../bin/metababel -u 1.stream_classes.yaml -d 2.stream_classes.yaml -t FILTER -p metababel3
#make -C FILTER.xprof
#babeltrace2  --plugin-path=SOURCE.xprof:FILTER.xprof  --component=source.metababel1.xprof --component=filter.metababel3.xprof | wc -l
