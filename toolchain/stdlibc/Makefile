AS = m2-assembler

all: build/__startup.o

build/__startup.o: __startup.asm
	$(AS) -o $@ $<

clean:
	rm -rf build
