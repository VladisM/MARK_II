.IMPORT main

__startup:

    MOV R0 R1
    MOV R0 R2
    MOV R0 R3
    MOV R0 R4
    MOV R0 R5
    MOV R0 R6
    MOV R0 R7
    MOV R0 R8
    MOV R0 R9
    MOV R0 R10
    MOV R0 R11
    MOV R0 R12

    .MVI    SP 0x7FF
    MOV     SP R13
    CALL    main

__startup_halt:
    BZ R0 __startup_halt
