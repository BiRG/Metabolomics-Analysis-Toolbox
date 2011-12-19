################
# Paths and Flags
################
SHELL := /bin/bash
INSTALL_LOCATION_INCLUDE ?= /usr/local/include
NAME := loss_fn
CPPFLAGS := -Wall -Wextra -pedantic -g -O3 -I$(INSTALL_LOCATION_INCLUDE)
LFLAGS := -lGClasses -lpng -lz

all: $(NAME)

$(NAME): main.o
	g++ -O3 -o $(NAME) main.o $(LFLAGS)

main.o: main.cpp

clean : 
	rm -f main.o $(NAME) 

