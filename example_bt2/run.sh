#!/bin/bash -xe

# Source
ruby -I ../lib ../bin/metababel --downstream fake_api.yaml --component SOURCE -o btx_source
gcc -g -o btx_source.so btx_source/*.c btx_source/metababel/*.c -I btx_source/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared
babeltrace2 --plugin-path=. --component=source.metababel_source.btx

#Filter
ruby -I../lib ../bin/metababel --upstream fake_api.yaml  --downstream fake_api.yaml --component FILTER -o btx_filter --params params.yaml
gcc -g -o btx_filter.so btx_filter/*.c btx_filter/metababel/*.c -I btx_filter/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared
babeltrace2 --plugin-path=. --component=source.metababel_source.btx  --component=filter.metababel_filter.btx --params='names="sched_switch,rcu_utilization,kmem_kfree"'
