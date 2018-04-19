PRG            = main
OBJ            = main.o
MCU_TARGET     = atmega48pb
OPTIMIZE       = -O1
MCU_AVRDUDE    = m48pb
PROGRAMMER     = usbasp

# You should not have to change anything below here.

CC             = avr-gcc

# Override is only needed by avr-lib build system.

override CFLAGS = -g -Wall $(OPTIMIZE) -mmcu=$(MCU_TARGET) $(DEFS)

OBJCOPY        = avr-objcopy
OBJDUMP        = avr-objdump

all: hex

$(PRG).elf: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm -rf *.o $(PRG).elf $(PRG).hex

hex:  $(PRG).hex

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

load: $(PRG).hex
	avrdude -p $(MCU_AVRDUDE) -c $(PROGRAMMER) -U flash:w:$<

