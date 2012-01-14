SHELL := /bin/bash
INSTALL_LOCATION_INCLUDE ?= /usr/local/include
CPPFLAGS := -Wall -Wextra -pedantic -g -O3 -I$(INSTALL_LOCATION_INCLUDE)
LFLAGS := -lGClasses -lpng -lz -lboost_serialization-mt

TARGETS=discretize_amp create_table create_prior_collection sum_tables

all: $(TARGETS)

######
# Executables
#####

discretize_amp: discretize_amp.o common.o
	g++ -O3 -o discretize_amp discretize_amp.o common.o $(LFLAGS)

create_table: create_table.o common.o
	g++ -O3 -o create_table create_table.o common.o $(LFLAGS)

sum_tables: sum_tables.o common.o
	g++ -O3 -o sum_tables sum_tables.o common.o $(LFLAGS)

create_prior_collection: create_prior_collection.o common.o
	g++ -O3 -o create_prior_collection create_prior_collection.o common.o \
		$(LFLAGS)



######
# Compiled object files
######

common.o: common.cpp common.hpp

discretize_amp.o: discretize_amp.cpp common.hpp

create_table.o: create_table.cpp common.hpp

sum_tables.o: sum_tables.cpp common.hpp

create_prior_collection.o: create_prior_collection.cpp common.hpp

clean : 
	rm -f *.o $(TARGETS)

