#!/bin/bash -xe

# Source
ruby -I ../lib ../bin/metababel --downstream fake_api.yaml --component SOURCE -o btx_source
gcc -o btx_source.so btx_source/*.c btx_source/metababel/*.c -I btx_source/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared

babeltrace2 --plugin-path=. --component=source.metababel_source.btx

# Sink
ruby -I../lib ../bin/metababel --upstream fake_api.yaml --component SINK -o btx_sink
gcc -o btx_sink.so btx_sink/*.c btx_sink/metababel/*.c -I btx_sink/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared

babeltrace2 --plugin-path=. --component=source.metababel_source.btx --component=sink.metababel_sink.btx

#Filter
ruby -I../lib ../bin/metababel --upstream fake_api.yaml  --downstream fake_api.yaml --component FILTER -o btx_filter
gcc -o btx_filter.so btx_filter/*.c btx_filter/metababel/*.c -I btx_filter/ -I ../include/ $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared

babeltrace2 --plugin-path=. --component=source.metababel_source.btx  --component=filter.metababel_filter.btx --component=sink.metababel_sink.btx
