#!/bin/bash -x

ruby ../main.rb -d 1.yaml -c SOURCE -p roger1 
make -C SOURCE.xprof/ 
babeltrace2 --plugin-path=SOURCE.xprof --component=source.roger1.xprof  --component=sink.text.details 

ruby ../main.rb -u 1.yaml -c SINK -p roger2
make -C SINK.xprof 
babeltrace2  --plugin-path=SOURCE.xprof:SINK.xprof  --component=source.roger1.xprof --component=sink.roger2.xprof 

ruby ../main.rb -u 1.yaml -d 2.yaml -c FILTER -p roger3
make -C FILTER.xprof
babeltrace2  --plugin-path=SOURCE.xprof:FILTER.xprof  --component=source.roger1.xprof --component=filter.roger3.xprof
