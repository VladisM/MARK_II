#include defs.asm

;start section (initialize system)
.ORG 0x00000000
start:
    OR R0 R0 R0
    MVIL SP 0x07FF   ;place a top of RAM into SP
    BZ R0 main

;main programm
main:
    ;config uart0 to 1200 baud 8n1
    MVIL R1 0x02ED
    ST R1 UCR0
    MOV R0 R4
    MVIL R1 0x00FF
    ST R1 DDRA
loop:
    MVIL R1 0x0048
    ST R1 UDR0
    CALL delay
    CALL set_led

    MVIL R1 0x0065
    ST R1 UDR0
    CALL delay
    CALL set_led

    MVIL R1 0x006c
    ST R1 UDR0
    CALL delay
    CALL set_led

    MVIL R1 0x006c
    ST R1 UDR0
    CALL delay
    CALL set_led

    MVIL R1 0x006f
    ST R1 UDR0
    CALL delay
    CALL set_led

    MVIL R1 0x0021
    ST R1 UDR0
    CALL delay
    CALL set_led

    BZ R0 loop

;simple delay function
delay:
    MVIL R2 0xFFFF
    MVIH R2 0x001F
delay_loop:
    DEC R2 R2
    CMP EQ R2 R0 R3
    BZ R3 delay_loop
    RET

;set led
set_led:
    MVIL R3 0x00FF
    XOR R4 R3 R4
    ST R4 PORTA
    RET
