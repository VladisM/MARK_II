; STDIO library
;
; Part of MARK II project. For informations about license, please
; see file /LICENSE .
;
; author: Vladislav Mlejnecký
; email: v.mlejnecky@seznam.cz


.EXPORT STDIO_UART0_RX_ISR
.EXPORT STDIO_UART0_TX_ISR
.EXPORT STDIO_PRINT
.EXPORT STDIO_READ_BYTES
.EXPORT STDIO_GET_COUNT

.CONS UDR0     0x00010A
.CONS UCR0     0x00010B

inRxBuffer:
.DAT 0x00
rxBuffer:
.DS 64
txSended:
.DAT 0x01

STDIO_UART0_RX_ISR:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4

    ;load data
    LD UDR0 R1             ;data from UART is in R1
    LD inRxBuffer R2       ;R2 is pointer in buffer
    MVIA R3 rxBuffer       ;R3 is base address of buffer

    ;calc address for incoming data
    ADD R3 R2 R4
    ;store data into buffer
    STI R1 R4

    ;increment pointer and store it back into memory
    INC R2 R2
    ST R2 inRxBuffer

    ;restore previous state
    POP R4
    POP R3
    POP R2
    POP R1

    ;return back
    RET


;---------------------------------------
; STDIO_READ_BYTE
;
; Read specified amount of bytes from stdio.
; Maximum lenght is 64. Data from buffer will be
; stored in given location
;
; Arguments
;   R1 - Byte count to read
;   R2 - Pointer into memory where result will be stored
; Return
;   None

STDIO_READ_BYTES:

    PUSH R1     ;count of byte to read - argument
    PUSH R2     ;pointer into result
    PUSH R3     ;count of char in buffer
    PUSH R4     ;address of buffer

    PUSH R5     ;readed byte counter

    PUSH R6     ;temp reg for address
    PUSH R7     ;temp reg for byte
    PUSH R8     ;counter for moving buffer to the left
    PUSH R9     ;top of buffer

    ;load buffer data; bytes count in buff and buff address
    LD inRxBuffer R3
    MVIA R4 rxBuffer

    ;inicialize counter
    MOV R0 R5

read_loop:

    ;compute address for reading
    ADD R4 R5 R6
    ;load data from buffer
    LDI R6 R7
    ;compute address for writing
    ADD R2 R5 R6
    ;store data into destination buffer
    STI R7 R6
    ;increment counter
    INC R5 R5
    ;decrement buffer count
    DEC R3 R3

    ;compare counter with argument and goto read_loop when there are another byte to read
    CMP EQ R5 R1 R6
    BZ R6 read_loop

    ;restore counter of byte in buffer
    ST R3 inRxBuffer

    ;--
    ;now, we have move RX buff to the left

    MOV R0 R8 ; init new counter
    .MVI R9 64 ;set top

read_move_buff_left_loop:
    ;compare counter with top and jump into finish when equals
    CMP EQ R5 R9 R6
    BNZ R6 read_move_buff_left_finish

    ;calc address of byte from buffer
    ADD R4 R5 R6
    ;load it
    LDI R6 R7
    ;calc address of new byte location
    ADD R4 R8 R6
    ;store byte back
    STI R7 R6

    ;increment counters
    INC R8 R8
    INC R5 R5

    BZ R0 read_move_buff_left_loop

read_move_buff_left_finish:

    ;restore registers from stack
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    ;return
    RET

;---------------------------------------
; STDIO_UART0_TX_ISR
;
; Call this when uart0_tx interrupt come
; this inform STDIO_PRINT about that uart
; is prepared for sending next byte
;
; Arguments
;   None
; Return
;   None

STDIO_UART0_TX_ISR:
    ;just infor about completed sending
    ST R0 txSended
    RET


;---------------------------------------
; STDIO_PRINT
;
; Print string into standart io
; print until reach 0x00 byte
;
; Arguments
;   R1 - pointer to string that will be printed
; Return
;   None

STDIO_PRINT:
    PUSH R2
    PUSH R1

print_loop:

    ;load data from input string
    LDI R1 R2

    ;if actual data is 0x00 we reach end of string
    BZ R2 print_loop_end

    ;send one byte
    ST R2 UDR0

    ;increment counter
    INC R1 R1

    ;wait until byte is sended
print_wait_loop:
    LD txSended R2
    CMP EQ R0 R2 R2
    BZ R2 print_wait_loop

    ;if we are here, byte is sended and uart can send another
    BZ R0 print_loop

    ;there is end of printing
print_loop_end:
    POP R1
    POP R2
    RET

;---------------------------------------
; STDIO_GET_COUNT
;
; Get number of bytes in rx buffer
;
; Arguments
;   None
; Return
;   R1 - count of bytes

STDIO_GET_COUNT:
    LD inRxBuffer R1
    RET
