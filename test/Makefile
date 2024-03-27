SO = ${BTX_SO_UUID}  
SRC = ${BTX_SRC}
METABABEL_ROOT= .

# linker
LD = $(CXX)

# C/C++ Flags
CPPFLAGS = $(shell pkg-config --cflags babeltrace2) -fpic -Wall -Werror 
# include flags
INCLUDES = -I $(SRC)/ -I $(METABABEL_ROOT)/include/
# linker flags
LDFLAGS = $(shell pkg-config --libs babeltrace2) --shared

SOURCES := $(wildcard $(SRC)/*.c $(SRC)/*.cpp $(SRC)/metababel/*.c)

OBJECTS := \
	$(patsubst $(SRC)/%.c, $(SRC)/%.o, $(wildcard $(SRC)/*.c)) \
	$(patsubst $(SRC)/%.cpp, $(SRC)/%.o, $(wildcard $(SRC)/*.cpp)) \
        $(patsubst $(SRC)/metababel/%.c, $(SRC)/metababel/%.o, $(wildcard $(SRC)/metababel/*.c))

COMPILE.c = $(CC) $(INCLUDES) $(CPPFLAGS) -c -o $@
# compile C++ source
COMPILE.cxx = $(CXX) $(INCLUDES) $(CPPFLAGS) -c -o $@
# link objects
LINK.so = $(LD) $(LDFLAGS) $(OBJECTS) -o $@

%.o: %.c
	$(COMPILE.c) $<

%.o: %.cpp
	$(COMPILE.cxx) $<

$(SO): $(SRC) $(OBJ) $(BIN) $(OBJECTS)
	$(LINK.so)

.PHONY: clean
clean:
	$(RM) $(OBJECTS) $(SO)
