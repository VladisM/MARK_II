#include defs.asm

;start section (initialize system)
.ORG 0x00000000
start:
    OR R0 R0 R0
    MVIL SP 0x07FF   ;place a top of RAM into SP
    BZ R0 main

;main program
main:
    MVIL R2 0x1000

    MVIL R1 0x13C8
    STI R1 R2

    MVIL R1 0x13E5
    INC R2 R2
    STI R1 R2

    MVIL R1 0x13Ec
    INC R2 R2
    STI R1 R2

    MVIL R1 0x13Ec
    INC R2 R2
    STI R1 R2

    MVIL R1 0x13Ef
    INC R2 R2
    STI R1 R2

    MVIL R1 0x0121
    INC R2 R2
    STI R1 R2

loop:
    BZ R0 loop
