#!/bin/bash -xe

# Source
ruby -I ../lib ../bin/metababel --downstream fake_api.yaml --component SOURCE -o btx_source
gcc -g -o btx_source.so btx_source/*.c btx_source/metababel/*.c -I btx_source/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared
babeltrace2 --plugin-path=. --component=source.metababel_source.btx

# Sink
ruby -I../lib ../bin/metababel --upstream fake_api.yaml --component SINK -o btx_sink
gcc -g -o btx_sink.so btx_sink/*.c btx_sink/metababel/*.c -I btx_sink/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared
babeltrace2 --plugin-path=. --component=source.metababel_source.btx --component=sink.metababel_sink.btx

# Filter
ruby -I../lib ../bin/metababel --upstream fake_api.yaml  --downstream fake_api.yaml --component FILTER -o btx_filter
gcc -g -o btx_filter.so btx_filter/*.c btx_filter/metababel/*.c -I btx_filter/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared
babeltrace2 --plugin-path=. --component=source.metababel_source.btx  --component=filter.metababel_filter.btx --component=sink.metababel_sink.btx

# Source timestamp
ruby -I ../lib ../bin/metababel --downstream dust.yaml --component SOURCE -o btx_dust -p dust --params dust_params.yaml
gcc -g -o btx_source.so btx_dust/*.c btx_dust/metababel/*.c -I btx_dust/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared
babeltrace2 --plugin-path=. --component=source.dust.btx  --params='path="./btx_dust/dust.txt"'

# Filter timestamp
ruby -I../lib ../bin/metababel --upstream dust.yaml  --downstream dust.yaml --component FILTER -p distill -c theone -o btx_filter_distill --params dust_params.yaml
gcc -g -o btx_filter_distill.so btx_filter_distill/*.c btx_filter_distill/metababel/*.c -I btx_filter_distill/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared
babeltrace2 --plugin-path=. --component=source.dust.btx  --params='path="./btx_dust/dust.txt"' --component=filter.distill.theone --params='names="sched_switch,rcu_utilization,kmem_kfree"'

# Source timestamp
ruby -I ../lib ../bin/metababel --downstream hip_model.yaml --component SOURCE -o btx_source_hip -p hip_sp
gcc -g -o btx_source_hip.so btx_source_hip/*.c btx_source_hip/metababel/*.c -I btx_source_hip/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared
babeltrace2 --plugin-path=. --component=source.hip_sp.btx

# Filter timestamp
ruby -I../lib ../bin/metababel --upstream hip_model.yaml --downstream interval_model.yaml --component FILTER -p hip_fp -o btx_filter_hip
gcc -g btx_filter_hip/*.c btx_filter_hip/metababel/*.c -I btx_filter_hip/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic -c
g++ -g btx_filter_hip/*.cpp -I btx_filter_hip/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic -c
g++ -g -o btx_filter_hip.so *.o -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared
babeltrace2 --plugin-path=. --component=source.hip_sp.btx --component=filter.hip_fp.btx
