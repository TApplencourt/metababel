CC ?= gcc
CXX ?= g++
CFLAGS = -Wall -fPIC -Werror -O0 
CXXFLAGS = -Wall -fPIC -std=c++17 -Werror -O0
CXXFLAGS_DEMANGLE = -DHAVE_DEMANGLE_H -fPIC
CFFLAGS_BT2 = $(pkg-config --cflags babeltrace2)
LDFLAGS_BT2 = $(pkg-config --libs babeltrace2)
LDFLAGS_DEMANGLE = -liberty
METABABEL_ROOT = ../..

aggregation.so: aggregation.o upstream.o aggregation_callbacks.o downstream.o params.o
	$(CXX) $^ -o aggregation.so -shared $(LDFLAGS_DEMANGLE) $(LDFLAGS_BT2)
 
aggregation.o: aggregation.c
	$(CC) aggregation.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

upstream.o: upstream.c
	$(CC) upstream.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c 

aggregation_callbacks.o: aggregation_callbacks.cpp downstream.c
	$(CXX) aggregation_callbacks.cpp -I $(METABABEL_ROOT)/include $(CXXFLAGS)  -c

downstream.o: downstream.c 
	$(CC) downstream.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

params.o: params.c
	$(CC) params.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

clean:
	rm -f *.o *.so component.h downstream.{h,c} upstream.{h,c} params.c aggregation.c
