CC ?= gcc
CXX ?= g++
CFLAGS = -Wall -fPIC -Werror -O0 
CXXFLAGS = -Wall -fPIC -std=c++17 -Werror -O0
CXXFLAGS_DEMANGLE = -DHAVE_DEMANGLE_H -fPIC
CFFLAGS_BT2 = $(pkg-config --cflags babeltrace2)
LDFLAGS_BT2 = $(pkg-config --libs babeltrace2)
LDFLAGS_DEMANGLE = -liberty
METABABEL_ROOT = ../..

aggregation.so: aggregation.o dispatch.o aggregation_callbacks.o create.o params.o
	$(CXX) $^ -o aggregation.so -shared $(LDFLAGS_DEMANGLE) $(LDFLAGS_BT2)
 
aggregation.o: aggregation.c
	$(CC) aggregation.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

dispatch.o: dispatch.c
	$(CC) dispatch.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c 

aggregation_callbacks.o: aggregation_callbacks.cpp create.c
	$(CXX) aggregation_callbacks.cpp -I $(METABABEL_ROOT)/include $(CXXFLAGS)  -c

create.o: create.c 
	$(CC) create.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

params.o: params.c
	$(CC) params.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

clean:
	rm -f *.o *.so component.h create.{h,c} dispatch.{h,c} params.c aggregation.c
