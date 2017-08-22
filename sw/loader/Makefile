all: loader.mif

loader.mif: loader.ldm
	m2-ldm2mif -r 0x000000 -s 8 loader.ldm

loader.ldm: loader.asm
	m2-assembler --skip-linker loader.asm

install: loader.mif
	cp loader.mif ./../../fpga/src/rom/rom.mif

clean:
	rm -f *.ldm

clean_all: clean
	rm -f *.mif
