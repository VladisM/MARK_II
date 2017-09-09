#---------------------------------------------------------
# This is example Makefile for MARK-II C based projects.
#
# usage: Change content of all variables defined in head
# of Makefile as you need and then type:
#
#   $ make
#

# name of final ldm
PRG          = uart
# list all object files
OBJS         = uart.o

# where MARK-II loader is listening
LOADER_PORT  = /dev/ttyUSB0
# base address where you want load your ldm
BASE_ADDRESS = 0x400

# size of ROM for storing mif
MIF_SIZE = 8
# relocate of source into this address
MIF_REL = 0x0000

#
#
# You shouldn't change anything bellow.
#---------------------------------------------------------



#---------------
# library paths
SPL = $(HOME)/m2_toolchain/spl
STDLIBC = $(HOME)/m2_toolchain/stdlibc

#---------------
# flags
CFLAGS = -I$(SPL) -quiet -c99
LDFLAGS = -o $(PRG).ldm $(STDLIBC)/__startup.o

#---------------
# define tools
CC = m2-vbcc
LK = m2-linker
AS = m2-assembler
LD = m2-loader
L2M = m2-ldm2mif

#---------------
# common rules

.PHONY: clean load

all: $(PRG).ldm

mif: $(PRG).ldm
	$(L2M) -s $(MIF_SIZE) -r $(MIF_REL) $(PRG).ldm

$(PRG).ldm: $(OBJS)
	$(LK) $(LDFLAGS) $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -o=$(@:.o=.asm) $<
	$(AS) -o $@ $(<:.c=.asm)

clean:
	rm -rf *.asm *.o *.ldm

load: $(PRG).ldm
	$(LD) -b $(BASE_ADDRESS) -p $(LOADER_PORT) $(PRG).ldm
