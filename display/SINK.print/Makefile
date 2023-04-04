CC ?= gcc
CXX ?= g++
CFLAGS = -Wall -fPIC -Werror -O0
CXXFLAGS = -Wall -fPIC -std=c++17 -Werror -O0
CXXFLAGS_DEMANGLE = -DHAVE_DEMANGLE_H -fPIC
CFFLAGS_BT2 = $(pkg-config --cflags babeltrace2)
LDFLAGS_BT2 = $(pkg-config --libs babeltrace2)
METABABEL_ROOT = ../..
LDFLAGS_DEMANGLE = -liberty

print.so: print.o upstream.o print_callbacks.o params.o my_demangle.o
	$(CXX) $^ -o print.so -shared $(LDFLAGS_DEMANGLE) $(LDFLAGS_BT2)
 
print.o: print.c
	$(CC) print.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

upstream.o: upstream.c
	$(CC) upstream.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c 

print_callbacks.o: print_callbacks.cpp 
	$(CXX) print_callbacks.cpp -I $(METABABEL_ROOT)/include $(CXXFLAGS)  -c

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
	rm -f *.o *.so component.h upstream.{h,c} params.c print.c