CC ?= gcc
CXX ?= g++
CFLAGS = -Wall -fPIC
CXXFLAGS = -Wall -fPIC -std=c++17
CXXFLAGS_DEMANGLE = -DHAVE_DEMANGLE_H -fPIC
CFFLAGS_BT2 = $(pkg-config --cflags babeltrace2)
LDFLAGS_BT2 = $(pkg-config --libs babeltrace2)
LDFLAGS_DEMANGLE = -liberty
METABABEL_ROOT = ../..

xprof.so: xprof.o dispatch.o my_callbacks.o params.o my_demangle.o
	$(CXX) $^ -o xprof.so -shared $(LDFLAGS_DEMANGLE) $(LDFLAGS_BT2)
 
xprof.o: xprof.c
	$(CC) xprof.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

dispatch.o: dispatch.c
	$(CC) dispatch.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c 

my_callbacks.o: my_callbacks.cpp my_callbacks.hpp 
	$(CXX) my_callbacks.cpp -I $(METABABEL_ROOT)/include $(CXXFLAGS)  -c

params.o: params.c
	$(CC) params.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

# For C++ Compiler
my_demangle.o: my_demangle.c my_demangle.h
	$(CXX) my_demangle.c $(CXXFLAGS_DEMANGLE) -c

# For C Compiler
# my_demangle.o: my_demangle.c my_demangle.h
# 	$(CC) my_demangle.c -fPIC  -c

clean:
	rm -f *.o *.so
