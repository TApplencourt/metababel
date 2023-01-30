#!/bin/bash -x

ruby ../main.rb -d 1.stream_classes.yaml -t SOURCE -p metababel1
make -C SOURCE.xprof/
babeltrace2 --plugin-path=SOURCE.xprof --component=source.metababel1.xprof  --component=sink.text.details

ruby ../main.rb -u 1.stream_classes.yaml -t SINK -p metababel2
make -C SINK.xprof
babeltrace2  --plugin-path=SOURCE.xprof:SINK.xprof  --component=source.metababel1.xprof --component=sink.metababel2.xprof

ruby ../main.rb -u 1.stream_classes.yaml -d 2.stream_classes.yaml -t FILTER -p metababel3
make -C FILTER.xprof
babeltrace2  --plugin-path=SOURCE.xprof:FILTER.xprof  --component=source.metababel1.xprof --component=filter.metababel3.xprof
