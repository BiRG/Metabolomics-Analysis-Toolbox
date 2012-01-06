SHELL := /bin/bash
INSTALL_LOCATION_INCLUDE ?= /usr/local/include
CPPFLAGS := -Wall -Wextra -pedantic -g -I$(INSTALL_LOCATION_INCLUDE)
LFLAGS := -lGClasses -lpng -lz

TARGETS=discretize_amp create_table

all: $(TARGETS)

######
# Executables
#####

discretize_amp: discretize_amp.o common.o
	g++ -O3 -o discretize_amp discretize_amp.o $(LFLAGS)

create_table: create_table.o common.o
	g++ -O3 -o create_table create_table.o $(LFLAGS)

######
# Compiled object files
######

common.o: common.cpp common.hpp

discretize_amp.o: discretize_amp.cpp common.hpp

create_table.o: create_table.cpp common.hpp

clean : 
	rm -f *.o $(TARGETS)

