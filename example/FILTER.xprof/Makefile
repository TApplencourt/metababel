CC ?= gcc
CXX ?= g++
CFLAGS = -Wall -fPIC
CFFLAGS_BT2 = $(pkg-config --cflags babeltrace2)
LDFLAGS_BT2 = $(pkg-config --libs babeltrace2)
METABABEL_ROOT = ../..

xprof.so: xprof.o upstream.o my_callbacks.o downstream.o params.o
	$(CXX) $^ -o xprof.so -shared $(LDFLAGS_BT2)
 
xprof.o: xprof.c
	$(CC) xprof.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

upstream.o: upstream.c
	$(CC) upstream.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c 

my_callbacks.o: my_callbacks.c
	$(CC) my_callbacks.c -I $(METABABEL_ROOT)/include $(CFLAGS)  -c

downstream.o: downstream.c
	$(CC) downstream.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

params.o: params.c
	$(CC) params.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

clean:
	rm -f *.o *.so
