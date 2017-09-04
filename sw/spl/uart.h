#ifndef SPL_UART_included
#define SPL_UART_included

#define UART0_BASE 0x000120
#define UART1_BASE 0x000124
#define UART2_BASE 0x000128

#define UTDR0     (*(unsigned int *)(UART0_BASE + 0))
#define URDR0     (*(unsigned int *)(UART0_BASE + 1))
#define USR0      (*(unsigned int *)(UART0_BASE + 2))
#define UCR0      (*(unsigned int *)(UART0_BASE + 3))

#define UTDR1     (*(unsigned int *)(UART1_BASE + 0))
#define URDR1     (*(unsigned int *)(UART1_BASE + 1))
#define USR1      (*(unsigned int *)(UART1_BASE + 2))
#define UCR1      (*(unsigned int *)(UART1_BASE + 3))

#define UTDR2     (*(unsigned int *)(UART2_BASE + 0))
#define URDR2     (*(unsigned int *)(UART2_BASE + 1))
#define USR2      (*(unsigned int *)(UART2_BASE + 2))
#define UCR2      (*(unsigned int *)(UART2_BASE + 3))

#define UCR0_N     0x0000FFFF
#define UCR0_txen  0x00010000
#define UCR0_rxen  0x00020000
#define UCR0_inten 0x00040000
#define UCR0_rfint 0x00080000
#define UCR0_rhint 0x00100000
#define UCR0_rxint 0x00200000
#define UCR0_teint 0x00400000
#define UCR0_thint 0x00800000
#define UCR0_txint 0x01000000

#define USR0_rxcount 0x0000003F
#define USR0_rxcount 0x00000FC0
#define USR0_rfif 0x00001000
#define USR0_rhif 0x00002000
#define USR0_rxif 0x00004000
#define USR0_teif 0x00008000
#define USR0_thif 0x00010000
#define USR0_txif 0x00020000

#define UCR0_N     0x0000FFFF
#define UCR0_txen  0x00010000
#define UCR0_rxen  0x00020000
#define UCR0_inten 0x00040000
#define UCR0_rfint 0x00080000
#define UCR0_rhint 0x00100000
#define UCR0_rxint 0x00200000
#define UCR0_teint 0x00400000
#define UCR0_thint 0x00800000
#define UCR0_txint 0x01000000

#define USR1_rxcount 0x0000003F
#define USR1_rxcount 0x00000FC0
#define USR1_rfif 0x00001000
#define USR1_rhif 0x00002000
#define USR1_rxif 0x00004000
#define USR1_teif 0x00008000
#define USR1_thif 0x00010000
#define USR1_txif 0x00020000

#define UCR0_N     0x0000FFFF
#define UCR0_txen  0x00010000
#define UCR0_rxen  0x00020000
#define UCR0_inten 0x00040000
#define UCR0_rfint 0x00080000
#define UCR0_rhint 0x00100000
#define UCR0_rxint 0x00200000
#define UCR0_teint 0x00400000
#define UCR0_thint 0x00800000
#define UCR0_txint 0x01000000

#define USR2_rxcount 0x0000003F
#define USR2_rxcount 0x00000FC0
#define USR2_rfif 0x00001000
#define USR2_rhif 0x00002000
#define USR2_rxif 0x00004000
#define USR2_teif 0x00008000
#define USR2_thif 0x00010000
#define USR2_txif 0x00020000

#endif
