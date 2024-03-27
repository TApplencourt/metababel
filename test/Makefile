SRC = ${BTX_SRC}
METABABEL_ROOT= .

CPPFLAGS = -I $(SRC)/ -I $(METABABEL_ROOT)/include/ $(shell pkg-config --cflags babeltrace2) -fpic -Wall -Werror
LDFLAGS = $(shell pkg-config --libs babeltrace2) --shared

CFILES   = $(wildcard $(SRC)/*.c) $(wildcard $(SRC)/metababel/*.c)
CPPFILES = $(wildcard $(SRC)/*.cpp)
OBJFILES = $(CPPFILES:.cpp=.o) $(CFILES:.c=.o)

${BTX_SO_UUID}: $(OBJFILES)
	$(CXX) $(LDFLAGS) $(OBJFILES) -o $@

.PHONY: clean
clean:
	$(RM) $(OBJFILES) ${BTX_SO_UUID}
