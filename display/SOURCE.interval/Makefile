CC ?= gcc
CXX ?= g++
CFLAGS = -Wall -fPIC -Werror
CFFLAGS_BT2 = $(pkg-config --cflags babeltrace2)
LDFLAGS_BT2 = $(pkg-config --libs babeltrace2)
METABABEL_ROOT = ../..

interval.so: interval.o interval_callbacks.o downstream.o params.o
	$(CXX) $^ -o interval.so -shared $(LDFLAGS_BT2)
 
interval.o: interval.c
	$(CC) interval.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

interval_callbacks.o: interval_callbacks.c
	$(CC) interval_callbacks.c -I $(METABABEL_ROOT)/include $(CFLAGS)  -c

downstream.o: downstream.c
	$(CC) downstream.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

params.o: params.c
	$(CC) params.c -I $(METABABEL_ROOT)/include $(CFLAGS) $(CFFLAGS_BT2) -c

# For test purposes
clean:
	rm -f *.o *.so component.h downstream.{h,c} interval_callbacks.c interval.c params.c