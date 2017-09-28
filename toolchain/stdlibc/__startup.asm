.IMPORT main

__startup:

    OR R0 R0 R1
    OR R0 R0 R2
    OR R0 R0 R3
    OR R0 R0 R4
    OR R0 R0 R5
    OR R0 R0 R6
    OR R0 R0 R7
    OR R0 R0 R8
    OR R0 R0 R9
    OR R0 R0 R10
    OR R0 R0 R11
    OR R0 R0 R12

    .MVI SP 0x7FF
    OR SP R0 R13
    CALL    main

__startup_halt:
    BZ R0 __startup_halt
