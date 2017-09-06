#ifndef SPL_INTDRV_included
#define SPL_INTDRV_included

#define INTDRV_BASE 0x000108

#define INTMR (*(unsigned int *)(INTDRV_BASE + 0))

#define INTMR_systim_en 0x00000001
#define INTMR_uart0_en  0x00000100
#define INTMR_uart1_en  0x00000200
#define INTMR_uart2_en  0x00000400
#define INTMR_tim0_en   0x00004000
#define INTMR_tim1_en   0x00008000
#define INTMR_tim2_en   0x00010000
#define INTMR_tim3_en   0x00020000
#define INTMR_ps0_en    0x00040000

#endif
