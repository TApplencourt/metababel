CC ?= gcc
CXX ?= g++
CFLAGS = -Wall -fPIC
CXXFLAGS = -Wall -fPIC -std=c++17
CXXFLAGS_DEMANGLE = -DHAVE_DEMANGLE_H -fPIC
CFFLAGS_BT2 = $(pkg-config --cflags babeltrace2)
LDFLAGS_BT2 = $(pkg-config --libs babeltrace2)
LDFLAGS_DEMANGLE = -liberty
METABABEL_ROOT = ../..

btx_main.so: btx_main.o btx_upstream.o btx_component.o callbacks.o my_demangle.o
	$(CXX) $^ -o btx_main.so -shared $(LDFLAGS_DEMANGLE) $(LDFLAGS_BT2)
 
btx_main.o: btx_main.c
	$(CC) btx_main.c -I $(METABABEL_ROOT)/include -I . $(CFLAGS) $(CFFLAGS_BT2) -c

btx_upstream.o: metababel/btx_upstream.c
	$(CC) metababel/btx_upstream.c -I $(METABABEL_ROOT)/include -I . $(CFLAGS) $(CFFLAGS_BT2) -c 

btx_component.o: metababel/btx_component.c
	$(CC) metababel/btx_component.c -I $(METABABEL_ROOT)/include -I . $(CFLAGS) $(CFFLAGS_BT2) -c

callbacks.o: callbacks.cpp callbacks.hpp 
	$(CXX) callbacks.cpp -I $(METABABEL_ROOT)/include -I . $(CXXFLAGS)  -c

# btx_params.o: metababel/btx_params.c
# 	$(CC) metababel/btx_params.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

# For C++ Compiler
my_demangle.o: my_demangle.c my_demangle.h
	$(CXX) my_demangle.c $(CXXFLAGS_DEMANGLE) -c

# For C Compilers
# my_demangle.o: my_demangle.c my_demangle.h
# 	$(CC) my_demangle.c -fPIC  -c

# For test purposes
clean:
	rm -f *.o *.so metababel/* callbacks.c btx_main.c
	rmdir metababel
