; Example and test code for stdio library
;
; Part of MARK II project. For informations about license, please
; see file /LICENSE .
;
; author: Vladislav Mlejnecký
; email: v.mlejnecky@seznam.cz

.IMPORT STDIO_UART0_RX_ISR STDIO_UART0_TX_ISR STDIO_PRINT STDIO_READ_BYTES STDIO_GET_COUNT

.CONS INTMR 0x000108
.CONS UDR0     0x00010A
;start section (initialize system)
.ORG 0x00000000
start:
    ;init stack
    MVIL SP 0x07FF
    ;enable interrupt
    MVIL R1 0x0300
    ST R1 INTMR
    ;jump into program
    BZ R0 main

.ORG 0x00000020 ;UART0 tx ISR
    CALL STDIO_UART0_TX_ISR
    RETI
.ORG 0x00000022 ;UART0 rx ISR
    CALL STDIO_UART0_RX_ISR
    RETI

data:
    .DAT 0x48 0x65 0x6c 0x6c 0x6f 0x20 0x57 0x6f 0x72 0x6c 0x64 0x21 0x0A 0x00
data2:
    .DAT 0x00 0x00
main:
    MVIA R1 data
    CALL STDIO_PRINT

    ;wait for byte to come
wait_loop:
    CALL STDIO_GET_COUNT
    BZ R1 wait_loop

    CALL delay

    MVIA R2 data2
    .MVI R1 1
    CALL STDIO_READ_BYTES

    MVIA R1 data2
    CALL STDIO_PRINT

    BZ R0 wait_loop

halt:
    BZ R0 halt

;simple delay function
delay:
    MVIL R2 0x0FFF
    MVIH R2 0x0000
delay_loop:
    DEC R2 R2
    CMP EQ R2 R0 R3
    BZ R3 delay_loop
    RET
