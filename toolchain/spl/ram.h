#ifndef SPL_RAM_included
#define SPL_RAM_included

#define RAM0_beg 0x000400
#define RAM0_end 0x0007FF
#define RAM1_beg 0x100000
#define RAM1_end 0x101FFF

#define RAM0(OFFSET) (*(unsigned int *)(RAM0_beg + OFFSET))
#define RAM1(OFFSET) (*(unsigned int *)(RAM1_beg + OFFSET))

#endif
