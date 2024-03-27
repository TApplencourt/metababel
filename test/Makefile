SO = ${BTX_SO_UUID}
SRC = ${BTX_SRC}
METABABEL_ROOT= .

LD = $(CXX)

CPPFLAGS = $(shell pkg-config --cflags babeltrace2) -fpic -Wall -Werror
INCLUDES = -I $(SRC)/ -I $(METABABEL_ROOT)/include/
LDFLAGS = $(shell pkg-config --libs babeltrace2) --shared

CFILES   = $(wildcard $(SRC)/*.c) $(wildcard $(SRC)/metababel/*.c)
CPPFILES = $(wildcard $(SRC)/*.cpp)
OBJFILES = $(CPPFILES:.cpp=.o) $(CFILES:.c=.o)

COMPILE.c = $(CC) $(INCLUDES) $(CPPFLAGS) -c -o $@
COMPILE.cxx = $(CXX) $(INCLUDES) $(CPPFLAGS) -c -o $@
LINK.so = $(LD) $(LDFLAGS) $(OBJFILES) -o $@

$(SO): $(SRC) $(OBJ) $(BIN) $(OBJFILES)
	$(LINK.so)

.PHONY: clean
clean:
	$(RM) $(OBJFILES) $(SO)
