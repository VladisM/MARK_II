#ifndef SPL_included
#define SPL_included

#inclide "gpio.h"
#include "uart.h"
#include "timer.h"

#define SYSTCR   (*(unsigned int *)(0x000104))
#define SYSTVR   (*(unsigned int *)(0x000105))

#define INTMR    (*(unsigned int *)(0x000108))

#define KEYBOARD (*(unsigned int *)(0x000109))



#endif
