CC ?= gcc
CXX ?= g++
CFLAGS = -Wall -fPIC
CXXFLAGS = -Wall -fPIC -std=c++17
CXXFLAGS_DEMANGLE = -DHAVE_DEMANGLE_H -fPIC
CFFLAGS_BT2 = $(pkg-config --cflags babeltrace2)
LDFLAGS_BT2 = $(pkg-config --libs babeltrace2)
LDFLAGS_DEMANGLE = -liberty
METABABEL_ROOT = ../..

tally.so: tally.o dispatch.o tally_callbacks.o params.o my_demangle.o
	$(CXX) $^ -o tally.so -shared $(LDFLAGS_DEMANGLE) $(LDFLAGS_BT2)
 
tally.o: tally.c
	$(CC) tally.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

dispatch.o: dispatch.c
	$(CC) dispatch.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c 

tally_callbacks.o: tally_callbacks.cpp tally_callbacks.hpp 
	$(CXX) tally_callbacks.cpp -I $(METABABEL_ROOT)/include $(CXXFLAGS)  -c

params.o: params.c
	$(CC) params.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

# For C++ Compiler
my_demangle.o: my_demangle.c my_demangle.h
	$(CXX) my_demangle.c $(CXXFLAGS_DEMANGLE) -c

# For C Compilers
# my_demangle.o: my_demangle.c my_demangle.h
# 	$(CC) my_demangle.c -fPIC  -c

# For test purposes
clean:
	rm -f *.o *.so component.h dispatch.{h,c} params.c tally.c