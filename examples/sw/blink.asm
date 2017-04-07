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
main:
    MVIL R1 0x00FF
    ST R1 DDRA
    MOV R0 R1
loop:
    CALL set_led
    CALL delay
    BZ R0 loop

;simple delay function
delay:
    MVIL R2 0xFFFF
    MVIH R2 0x0002
delay_loop:
    DEC R2 R2
    CMP EQ R2 R0 R3
    BZ R3 delay_loop
    RET

;set led
set_led:
    MVIL R3 0x00FF
    XOR R1 R3 R1
    ST R1 PORTA
    RET

