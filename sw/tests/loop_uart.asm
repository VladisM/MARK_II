#include defs.asm

;start section (initialize system)
.ORG 0x00000000
start:
    OR R0 R0 R0
    MVIL SP 0x07FF   ;place a top of RAM into SP
    BZ R0 main

.ORG 0x00000022 ;UART0 rx ISR
    CALL UART0_RX_ISR
    RETI

;main program
.ORG 0x00000050
main:
    ;config uart0 to 1200 baud 8n1
    MVIL R1 0x02ED
    ST R1 UCR0
    ;set porta as output
    MVIL R1 0x00FF
    ST R1 DDRA
    ;enable interrupt from USART0 RX
    MVIL R1 0x0200
    ST R1 INTMR
loop:
    BZ R0 loop

;service routine, show data on LED and send them back
UART0_RX_ISR:
    LD UDR0 R1
    ST R1 PORTA
    ST R1 UDR0
    RET


