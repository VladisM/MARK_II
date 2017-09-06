#ifndef SPL_ROM_included
#define SPL_ROM_included

#define ROM0_beg 0x000000
#define ROM0_end 0x0000FF

#define ROM0(OFFSET) (*(unsigned int *)(ROM0_beg + OFFSET))

#endif
