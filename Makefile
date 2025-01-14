DIR_INC := ./inc
DIR_SRC := ./src
DIR_OBJ := ./obj

PREFIX :=$(shell pwd)
BINDIR ?= $(PREFIX)/bin
INCLUDE_DIRS ?=
LIBRARY_DIRS ?=

SRC := $(wildcard ${DIR_SRC}/*.cpp)
OBJ := $(patsubst %.cpp,${DIR_OBJ}/%.o,$(notdir ${SRC}))

TARGET := fastp

BIN_TARGET := ${TARGET}

CXX := g++ -Wl,--rpath=$(PREFIX)/lib
CXXFLAGS := -std=c++11 -pthread -g -O3 -I${DIR_INC} $(foreach includedir,$(INCLUDE_DIRS),-I$(includedir)) ${CXXFLAGS}
LIBS := -lisal -ldeflate -lpthread
STATIC_FLAGS := -static -Wl,--no-as-needed -pthread
LD_FLAGS := $(foreach librarydir,$(LIBRARY_DIRS),-L$(librarydir)) $(LIBS) $(LD_FLAGS)
STATIC_LD_FLAGS := $(foreach librarydir,$(LIBRARY_DIRS),-L$(librarydir)) $(STATIC_FLAGS) $(LIBS) $(STATIC_LD_FLAGS)


${BIN_TARGET}:${OBJ}
	$(CXX) $(OBJ) -o $@ $(LD_FLAGS) -L $(PREFIX)/lib

static:${OBJ}
	$(CXX) $(OBJ) -o ${BIN_TARGET} $(STATIC_LD_FLAGS) -L $(PREFIX)/lib

${DIR_OBJ}/%.o:${DIR_SRC}/%.cpp make_obj_dir
	$(CXX) -c $< -o $@ $(CXXFLAGS)

.PHONY:clean
.PHONY:static
clean:
	@if test -d $(DIR_OBJ) ; \
	then \
		find $(DIR_OBJ) -name *.o -delete; \
	fi
	@if test -e $(TARGET) ; \
	then \
		rm $(TARGET) ; \
	fi

make_obj_dir:
	@if test ! -d $(DIR_OBJ) ; \
	then \
		mkdir $(DIR_OBJ) ; \
	fi

install:
	install $(TARGET) $(BINDIR)/$(TARGET)
	@echo "Installed."
