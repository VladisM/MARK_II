# Registers
Register name | Purpose            |Register name | Purpose            
--------------|--------------------|--------------|--------------------------------
**R0**        | zero register      |**R8**        | 32b GPR
**R1**        | 32b GPR            |**R9**        | 32b GPR
**R2**        | 32b GPR            |**R10**       | 32b GPR
**R3**        | 32b GPR            |**R11**       | 32b GPR
**R4**        | 32b GPR            |**R12**       | 32b GPR
**R5**        | 32b GPR            |**R13**       | 32b GPR
**R6**        | 32b GPR            |**R14**       | Program counter
**R7**        | 32b GPR            |**R15**       | Stack pointer

GPR mean general purpose register, these registers are 32bit wide. Zero register is one of special registers, it always contain zero. You can write there whatever you want, but always read zero. Program counter (PC) and Stack pointer (SP) are implemented like any others registers but they are holding actual address in program and actual address of top of stack.

There is no limitation in register usage in instructions. Every instruction can work with every register include PC and SP. There is no register windows, banks or something like that.

# Memory space

CPU can address up to 2^20 words, whole memory space is linear. Everything is in one memory space, there is nothing like IO space, program space, data space. MARK II CPU following Von Neumann scheme, so program and also data is in one space. Peripherals and IO devices should be mapped there too. 

There are two instruction for working with memory. One is LD for reading from memory, and second is ST for writing into memory. Both instruction using absolute addressing, with address is stored in instruction code.

# Stack

Stack is used for storing returning address when calling subroutines or interrupts. It grow from up to down. So, you should set SP at end of ram. Currently there is no support for data operation with stack. 

# Instruction set architecture

Instruction              | Explanation
-------------------------|---------------------
**MOV RA RB**            | move reg RB into RA
**MVIL RA cons16**       | RA = (RA and x"FFFF0000") or cons16  
**RET**                  | return from subrutine
**ADD RA RB**            | RA = RA + RB
**SUB RA RB**            | RA = RA - RB 
**OR RA RB**             | RA = RA | RB
**AND RA RB**            | RA = RA & RB
**NOT RA**               | RA = ~RA
**XOR RA RB**            | RA = RA ^ RB
**ROL RA**               | RA = RA << 1
**ROR RA**               | RA = RA >> 1
**INC RA**               | RA = ++RA
**DEC RA**               | RA = --RA
**MVIH RA cons16**       | RA = (RA and x"0000FFFF") or (cons16 << 16)  
**RETI**                 | return from interrupt
**CALL addr20**          | call subroutine at addr20, store PC at stack
**LD RA addr20**         | RA = mem[addr20]
**ST RA addr20**         | mem[addr20] = RA
**BEQ RA RB addr20**     | if RA == RB then PC = addr20
**BNE RA RB addr20**     | if RA != RB then PC = addr20
**BLT RA RB addr20**     | if RA < RB then PC = addr20
**BLTU RA RB addr20**    | if RA < RB then PC = addr20 (comparing unsigned)
**BGE RA RB addr20**     | if RA >= RB then PC = addr20
**BGEU RA RB addr20**    | if RA >= RB then PC = addr20 (comparing unsigned)
