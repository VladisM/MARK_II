LIB = $(HOME)/m2_toolchain/spl
PORT = /dev/ttyUSB0
CCFLAG = -I$(LIB) -quiet -c99

all: blink.ldm


blink.ldm: blink.o startup.o
	m2-linker -o blink.ldm startup.o blink.o

startup.o: startup.asm
	m2-assembler startup.asm

blink.o: blink.asm
	m2-assembler blink.asm

blink.asm: blink.c
	m2-vbcc $(CCFLAG) blink.c


clean:
	rm -rf blink.asm blink.ldm *.o

load: blink.ldm
	m2-loader -p $(PORT) -b 0x400 blink.ldm
