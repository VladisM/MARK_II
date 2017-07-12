all: main.ldm

main.ldm: main.o stdio.o
	m2-linker -o main.ldm main.o stdio.o

main.o: main.asm
	m2-assembler main.asm

stdio.o: stdio.asm
	m2-assembler stdio.asm

clean:
	rm -f *.o
