CC ?= gcc
CXX ?= g++
CFLAGS = -Wall -fPIC
CFFLAGS_BT2 = $(pkg-config --cflags babeltrace2)
LDFLAGS_BT2 = $(pkg-config --libs babeltrace2)
METABABEL_ROOT = ../..

interval.so: interval.o interval_callbacks.o create.o params.o
	$(CXX) $^ -o interval.so -shared $(LDFLAGS_BT2)
 
interval.o: interval.c
	$(CC) interval.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

interval_callbacks.o: interval_callbacks.c
	$(CC) interval_callbacks.c -I $(METABABEL_ROOT)/include $(CFLAGS)  -c

create.o: create.c
	$(CC) create.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

params.o: params.c
	$(CC) params.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

# clean:
# 	rm -f *.o *.so

# For test purposes
clean:
	rm -f *.o *.so component.h create.{h.c} interval_callbacks.c interval.c params.c