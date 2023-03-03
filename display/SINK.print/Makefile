CC ?= gcc
CXX ?= g++
CFLAGS = -Wall -fPIC
CXXFLAGS = -Wall -fPIC -std=c++17
CFFLAGS_BT2 = $(pkg-config --cflags babeltrace2)
LDFLAGS_BT2 = $(pkg-config --libs babeltrace2)
METABABEL_ROOT = ../..

print.so: print.o dispatch.o print_callbacks.o params.o
	$(CXX) $^ -o print.so -shared $(LDFLAGS_BT2)
 
print.o: print.c
	$(CC) print.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

dispatch.o: dispatch.c
	$(CC) dispatch.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c 

print_callbacks.o: print_callbacks.cpp print_callbacks.hpp 
	$(CXX) print_callbacks.cpp -I $(METABABEL_ROOT)/include $(CXXFLAGS)  -c

params.o: params.c
	$(CC) params.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

# For test purposes
clean:
	rm -f *.o *.so component.h dispatch.{h,c} params.c print.c