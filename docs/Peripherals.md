**MARK II Peripherals are under hard development, see sources code for actual informations.**

# ROM
Simple memory for program store. CPU can read program from this but it is not able to write data there. Program is stored in ".mif" memory initialization files. This memory is initialized with content of specified file. ROM memory is 256 words long.

# RAM
Simple and fast memory. You can store your data there, you can also run program from there.

# GPIO
Simple peripheral, two 8bit input/outputs ports. Function is similar to AVR ports, there is two register, DDR and PORT, logical one in DDR set this pin as output, value written into right bit of PORT register will be on pin. When logical zero in in DDR register, CPU can read values what are connected to the pins through PORT register.

# Memory map
Peripheral | Start address | End address
-----------|---------------|------------
ROM        | 0x00000       | 0x000FF
GPIO       | 0x00100       | 0x00103
RAM        | 0x00400       | 0x007FF