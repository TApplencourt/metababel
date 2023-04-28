CC ?= gcc
CXX ?= g++
CFLAGS = -Wall -fPIC -Werror
CFFLAGS_BT2 = $(pkg-config --cflags babeltrace2)
LDFLAGS_BT2 = $(pkg-config --libs babeltrace2)
METABABEL_ROOT = ../..

btx_main.so: btx_main.o btx_downstream.o btx_component.o callbacks.o
	$(CXX) $^ -o btx_main.so -shared $(LDFLAGS_BT2)
 
btx_main.o: btx_main.c
	$(CC) btx_main.c -I $(METABABEL_ROOT)/include -I . $(CFLAGS) $(CFFLAGS_BT2) -c

btx_downstream.o: metababel/btx_downstream.c
	$(CC) metababel/btx_downstream.c -I $(METABABEL_ROOT)/include -I . $(CFLAGS) $(CFFLAGS_BT2) -c

btx_component.o: metababel/btx_component.c
	$(CC) metababel/btx_component.c -I $(METABABEL_ROOT)/include -I . $(CFLAGS) $(CFFLAGS_BT2) -c

callbacks.o: callbacks.c
	$(CC) callbacks.c -I $(METABABEL_ROOT)/include -I . $(CFLAGS)  -c

# For test purposes
clean:
	rm -f *.o *.so metababel/* callbacks.c btx_main.c
	rmdir metababel
