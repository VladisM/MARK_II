all: blink.ldm hello_uart.ldm keyboard.ldm loop_uart.ldm vga.ldm vgacolors.ldm

blink.ldm: blink.asm
	m2-assembler --skip-linker blink.asm

hello_uart.ldm: hello_uart.asm
	m2-assembler --skip-linker hello_uart.asm

keyboard.ldm: keyboard.asm
	m2-assembler --skip-linker keyboard.asm

loop_uart.ldm: loop_uart.asm
	m2-assembler --skip-linker loop_uart.asm

vga.ldm: vga.asm
	m2-assembler --skip-linker vga.asm

vgacolors.ldm: vgacolors.asm
	m2-assembler --skip-linker vgacolors.asm

clean:
	rm -f *.ldm
