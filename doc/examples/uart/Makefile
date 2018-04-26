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
OBJS         = main.o

# where MARK-II loader is listening
LOADER_PORT  = /dev/ttyUSB0
# base address where you want load your ldm
BASE_ADDRESS = 0x800000

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
BSP = $(HOME)/m2_toolchain/bsp
STDLIBC = $(HOME)/m2_toolchain/stdlibc

#---------------
# flags
CFLAGS = -I$(SPL) -I$(BSP) -quiet -c99
LDFLAGS = -o $(PRG).ldm -l $(BSP)/lib $(STDLIBC)/__startup.o

#---------------
# define tools
CC = m2-vbcc
LK = m2-linker
AS = m2-assembler
LD = m2-loader
L2M = m2-ldm2mif
DAS = m2-disassembler

#---------------
# common rules

.PHONY: clean load disasm install load_sram

all: $(PRG).ldm

$(PRG).mif: $(PRG).ldm
	$(L2M) -s $(MIF_SIZE) -r $(MIF_REL) $(PRG).ldm

$(PRG).ldm: $(OBJS)
	$(LK) $(LDFLAGS) $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -o=$(@:.o=.asm) $<
	$(AS) -o $@ $(<:.c=.asm)

clean:
	rm -rf *.asm *.o *.ldm *.mif *.disasm

load: $(PRG).ldm
	$(LD) -b $(BASE_ADDRESS) -p $(LOADER_PORT) $(PRG).ldm

install: $(PRG).mif
	cp $(PRG).mif ../../fpga/src/rom/rom.mif

disasm: $(PRG).mif
	$(DAS) -o $(PRG).disasm $(PRG).mif

load_sram: $(PRG).ldm
	$(LD) -b 0x100000 -p $(LOADER_PORT) $(PRG).ldm
