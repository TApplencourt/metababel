#!/bin/bash -xe

CFLAGS="$(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -fpic --shared -Werror"

# Source
ruby -I ../lib ../bin/metababel --downstream fake_api.yaml --component SOURCE -o btx_source
gcc -g -o btx_source.so btx_source/*.c btx_source/metababel/*.c -I btx_source/ -I ../include/ $CFLAGS
babeltrace2 --plugin-path=. --component=source.metababel_source.btx --component=sink.text.details

# Sink
ruby -I../lib ../bin/metababel --upstream fake_api.yaml --component SINK -o btx_sink
gcc -g -o btx_sink.so btx_sink/*.c btx_sink/metababel/*.c -I btx_sink/ -I ../include/ $CFLAGS
babeltrace2 --plugin-path=. --component=source.metababel_source.btx --component=sink.metababel_sink.btx

#Filter
ruby -I../lib ../bin/metababel --upstream fake_api.yaml  --downstream fake_api.yaml --component FILTER -o btx_filter
gcc -g -o btx_filter.so btx_filter/*.c btx_filter/metababel/*.c -I btx_filter/ -I ../include/ $CFLAGS 
babeltrace2 --plugin-path=. --component=source.metababel_source.btx  --component=filter.metababel_filter.btx --component=sink.metababel_sink.btx

# Source timestamp
ruby -I ../lib ../bin/metababel --downstream dust.yaml --component SOURCE -o btx_dust -p dust --params dust_params.yaml
gcc -g -o btx_source.so btx_dust/*.c btx_dust/metababel/*.c -I btx_dust/ -I ../include/ $CFLAGS
babeltrace2 --plugin-path=. --component=source.dust.btx  --params='path="./btx_dust/dust.txt"'
