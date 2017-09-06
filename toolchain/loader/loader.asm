; program loader from uart
;
; Part of MARK II project. For informations about license, please
; see file /LICENSE .
;
; author: Vladislav Mlejnecký
; email: v.mlejnecky@seznam.cz
;
;
; Registers description
;
; R1 - universal register using in main program
; R2 - universal register using in interrupt
; R3 - universal register using in interrupt
;
; R6 - temp variable
; R7 - bytenum variable
; R8 - wordnum variable
; R9 - count variable
; R10 - base variable
; R11 - mode variable
;

.CONS INTMR 0x000108

.CONS UTDR0 0x120
.CONS URDR0 0x121
.CONS USR0  0x122
.CONS UCR0  0x123

.CONS MODE_SYNC  0x01
.CONS MODE_BASE  0x02
.CONS MODE_COUNT 0x03
.CONS MODE_DATA  0x04
.CONS MODE_DONE  0x05
.CONS MODE_ERROR 0x06

;---------------------------------------
; init system
.ORG 0x00000000
start:
    ;init stack
    MVIL SP 0x07FF

    ;init variables
    MOV R0 R6
    MOV R0 R7
    MOV R0 R8
    MOV R0 R9
    MOV R0 R10
    .MVI R11 MODE_SYNC

    ;config uart0 to 1200 baud 8n1
    .MVI R1 0x002702ED
    ST R1 UCR0

    ;enable interrupt
    MVIL R1 0x0100
    ST R1 INTMR

    ;goto main program
    BZ R0 main

.ORG 0x00000020 ;UART0 RX ISR

    LD USR0 R2

    ;decide what code branch to execute - this is something like FSM
    .MVI R2 MODE_SYNC
    CMP EQ R2 R11 R2
    BNZ R2 mode_sync_code

    .MVI R2 MODE_BASE
    CMP EQ R2 R11 R2
    BNZ R2 mode_base_code

    .MVI R2 MODE_COUNT
    CMP EQ R2 R11 R2
    BNZ R2 mode_count_code

    .MVI R2 MODE_DATA
    CMP EQ R2 R11 R2
    BNZ R2 mode_data_code

    ;something is wrong if we are there :(
    RETI

;sync branch
mode_sync_code:

    ;if UDR0 != 0x55 then goto mode_sync_code_error
    LD URDR0 R2
    .MVI R3 0x55
    CMP EQ R2 R3 R2
    BZ R2 mode_sync_code_error

    ;send 0xAA responde for loader
    .MVI R3 0xAA
    ST R3 UTDR0

    ;mode = mode_base
    .MVI R11 MODE_BASE
    RETI

mode_sync_code_error:
    ;mode = MODE_ERROR
    .MVI R11 MODE_ERROR
    RETI


;base branch
mode_base_code:

    ;tmp << 8
    LSL 8 R6 R6

    ;tmp |= udr0
    LD URDR0 R2
    OR R2 R6 R6

    ;bytenum++
    INC R7 R7

    ;if bytenum == 3 then goto mode_base_code_wordcomplete else RETI
    .MVI R2 0x03
    CMP EQ R2 R7 R2
    BNZ R2 mode_base_code_wordcomplete

    BZ R0 signalize_and_reti

mode_base_code_wordcomplete:

    MOV R6 R10 ;base = tmp
    MOV R0 R7 ;bytenum = 0
    MOV R0 R6 ;tmp = 0
    .MVI R11 MODE_COUNT ;mode = MODE_COUNT

    BZ R0 signalize_and_reti

;count branch
mode_count_code:

    ;tmp << 8
    LSL 8 R6 R6

    ;tmp |= udr0
    LD URDR0 R2
    OR R2 R6 R6

    ;bytenum++
    INC R7 R7

    ;if bytenum == 3 then goto mode_count_code_wordcomplete else RETI
    .MVI R2 0x03
    CMP EQ R2 R7 R2
    BNZ R2 mode_count_code_wordcomplete

    BZ R0 signalize_and_reti

mode_count_code_wordcomplete:
    MOV R6 R9 ;count = tmp
    MOV R0 R7 ;bytenum = 0
    MOV R0 R6 ;tmp = 0
    .MVI R11 MODE_DATA ;mode = MODE_DATA

    BZ R0 signalize_and_reti


;data branch
mode_data_code:

    ;tmp << 8
    LSL 8 R6 R6

    ;tmp |= udr0
    LD URDR0 R2
    OR R2 R6 R6

    ;bytenum++
    INC R7 R7

    ;if bytenum == 4 then goto mode_data_code_wordcomplete else RETI
    .MVI R2 0x04
    CMP EQ R2 R7 R2
    BNZ R2 mode_data_code_wordcomplete

    BZ R0 signalize_and_reti

mode_data_code_wordcomplete:
    MOV R0 R7 ;bytenum = 0

    ;store address in R2
    ADD R8 R10 R2
    ;store word (from tmp) in calculated address
    STI R6 R2

    ;wordnum++
    INC R8 R8

    ;if wordnum == count then goto mode_data_code_complete else RETI
    CMP EQ R8 R9 R2
    BNZ R2 mode_data_code_complete

    BZ R0 signalize_and_reti

mode_data_code_complete:
    ;mode = MODE_DONE
    .MVI R11 MODE_DONE
    BZ R0 signalize_and_reti

signalize_and_reti:
    .MVI R2 0xBB
    ST R2 UTDR0
    RETI



main:
    ; if mode == MODE_DONE then goto base
    .MVI R1 MODE_DONE
    CMP EQ R1 R11 R1
    BNZ R1 start_loaded

    ; if mode == MODE_ERROR make horrible things!
    .MVI R1 MODE_ERROR
    CMP EQ R1 R11 R1
    BNZ R1 error_sig

    BZ R0 main

error_sig:
    BZ R0 error_sig


;goto loaded program
start_loaded:

    ;wait a bit
    .MVI R1 0xFFFFF
start_loaded_loop:
    DEC R1 R1
    BNZ R1 start_loaded_loop

    ;disable UART and jump into program
    ST R0 INTMR
    ST R0 UCR0
    LD USR0 R0
    BZI R0 R10
