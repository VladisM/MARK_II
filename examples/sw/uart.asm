#include constants.inc

;start section (initialize system)
.ORG 0x00000000
start:
    OR R0 R0 R0
    MVIL SP 0x07FF   ;place a top of RAM into SP
    BZ R0 main

#include int_vectors.inc

;main programm
.ORG 0x00000050

.DAT 0x48 0x65 0x6c 0x6c 0x6f 0x20 0x57 0x6f 0x72 0x6c 0x64 0x21 0x0A

main:
    ;config uart0 to 1200 baud 8n1
    MVIL R1 0x02ED
    ST R1 UCR0
    MOV R0 R4
    MVIL R1 0x00FF
    ST R1 DDRA

;prepare for sending
loop:
    MVIL R4 0x0050
    MVIL R5 0x005D

;send one char
send:
    LDI R4 R6           ;load data
    INC R4 R4           ;increment data pointer

    ST R6 UDR0          ;send
    CALL delay

    CMP EQ R4 R5 R6
    BZ R6 send          ;send next char

    CALL delay_long
    BZ R0 loop

;simple delay function
delay:
    MVIL R2 0xFFFF
    MVIH R2 0x0000
delay_loop:
    DEC R2 R2
    CMP EQ R2 R0 R3
    BZ R3 delay_loop
    RET

;longer delay
delay_long:
    MVIL R2 0xFFFF
    MVIH R2 0x000F
delay_long_loop:
    DEC R2 R2
    CMP EQ R2 R0 R3
    BZ R3 delay_long_loop
    RET


