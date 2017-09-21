#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  pass1objects.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz

from common import *

class item():

    def __init__(self, parrent, address):
        self.address = address
        self.parrent = parrent

class blob(item):

    def __init__(self, parrent, address, data):
        item.__init__(self, parrent, address)
        self.data = data
        self.relocation = False
        self.special = False

    def translate(self, symbol_table, special_symbol_table):
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.data)
        return checkSizeOfImmediate(self, 32, result[0])

class instruction(item):

    def __init__(self, parrent, address, opcode):
        item.__init__(self, parrent, address)
        self.opcode = opcode
        self.relocation = False
        self.special = False

        self.register_a = "R0"
        self.register_b = "R0"
        self.register_c = "R0"
        self.register_f = "R0"

        self.reg_a = 0
        self.reg_b = 0
        self.reg_c = 0
        self.reg_f = 0

        self.regs = 0

    def decodeRegs(self):
        self.reg_a = self.decodeRegName(self.register_a)
        self.reg_b = self.decodeRegName(self.register_b)
        self.reg_c = self.decodeRegName(self.register_c)
        self.reg_f = self.decodeRegName(self.register_f)

        self.regs = (self.reg_f << 20) | (self.reg_a << 8) | (self.reg_b << 4) | self.reg_c

    def decodeRegName(self, reg_name):
        reg = -1

        if   reg_name == "R0": reg = 0
        elif reg_name == "R1": reg = 1
        elif reg_name == "R2": reg = 2
        elif reg_name == "R3": reg = 3
        elif reg_name == "R4": reg = 4
        elif reg_name == "R5": reg = 5
        elif reg_name == "R6": reg = 6
        elif reg_name == "R7": reg = 7
        elif reg_name == "R8": reg = 8
        elif reg_name == "R9": reg = 9
        elif reg_name == "R10": reg = 10
        elif reg_name == "R11": reg = 11
        elif reg_name == "R12": reg = 12
        elif reg_name == "R13": reg = 13
        elif reg_name == "R14": reg = 14
        elif reg_name == "R15": reg = 15
        elif reg_name == "PC": reg = 14
        elif reg_name == "SP": reg = 15
        else: reg = -1

        if reg == -1:
            print "Error! Instruction '" + self.opcode + "' at " + self.parrent.fileName + "@" + str(self.parrent.lineNumber) + ". Invalid name of register."
            sys.exit(1)
        else:
            return reg

class RET(instruction):

    def __init__(self, parrent, address):
        instruction.__init__(self, parrent, address, 'RET')

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x01000000

class RETI(instruction):

    def __init__(self, parrent, address):
        instruction.__init__(self, parrent, address, 'RETI')

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x02000000

class CALLI(instruction):

    def __init__(self, parrent, address, register_1):
        instruction.__init__(self, parrent, address, 'CALLI')
        self.register_a = register_1

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x03000000

class PUSH(instruction):

    def __init__(self, parrent, address, register_1):
        instruction.__init__(self, parrent, address, 'PUSH')
        self.register_b = register_1

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x04000000

class POP(instruction):

    def __init__(self, parrent, address, register_1):
        instruction.__init__(self, parrent, address, 'POP')
        self.register_c = register_1

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x05000000

class LDI(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'LDI')
        self.register_a = register_1
        self.register_c = register_2

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x06000000

class STI(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'STI')
        self.register_b = register_1
        self.register_a = register_2

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x07000000

class BNZI(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'BNZI')
        self.register_f = register_1
        self.register_a = register_2

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x08000000

class BZI(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'BZI')
        self.register_f = register_1
        self.register_a = register_2

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x09000000

class CMPI(instruction):

    def __init__(self, parrent, address, comparison, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'CMPI')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3
        self.comparison = comparison

    def __decodeComparison(self):
        code = -1

        if   self.comparison == "EQ"  : code = 6;
        elif self.comparison == "NEQ" : code = 7;
        elif self.comparison == "L"   : code = 10;
        elif self.comparison == "LU"  : code = 14;
        elif self.comparison == "LE"  : code = 11;
        elif self.comparison == "LEU" : code = 15;
        elif self.comparison == "G"   : code = 8;
        elif self.comparison == "GU"  : code = 12;
        elif self.comparison == "GE"  : code = 9;
        elif self.comparison == "GEU" : code = 13;
        else: code = -1

        if code == -1:
            print "Error! Instruction '" + self.opcode + "' at " + self.parrent.fileName + "@" + str(self.parrent.lineNumber) + ". Invalid comparison name."
            sys.exit(1)
        else:
            return code


    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        comp = self.__decodeComparison()
        return self.regs | 0x0A000000 + (comp << 20)

class CMPF(instruction):

    def __init__(self, parrent, address, comparison, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'CMPF')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3
        self.comparison = comparison

    def __decodeComparison(self):
        code = -1

        if   self.comparison == "EQ"  : code = 0;
        elif self.comparison == "NEQ" : code = 5;
        elif self.comparison == "L"   : code = 3;
        elif self.comparison == "LE"  : code = 4;
        elif self.comparison == "G"   : code = 1;
        elif self.comparison == "GE"  : code = 2;
        else: code = -1

        if code == -1:
            print "Error! Instruction '" + self.opcode + "' at " + self.parrent.fileName + "@" + str(self.parrent.lineNumber) + ". Invalid comparison name."
            sys.exit(1)
        else:
            return code

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        comp = self.__decodeComparison()
        return self.regs | 0x0B000000 + (comp << 20)

class MULU(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'MULU')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0C000000

class MUL(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'MUL')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0C100000

class ADD(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'ADD')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0C600000

class SUB(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'SUB')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0C700000

class INC(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'INC')
        self.register_a = register_1
        self.register_c = register_2

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0C800000

class DEC(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'DEC')
        self.register_a = register_1
        self.register_c = register_2

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0C900000

class AND(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'AND')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0CA00000

class OR(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'OR')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0CB00000

class XOR(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'XOR')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0CC00000

class NOT(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'NOT')
        self.register_a = register_1
        self.register_c = register_2

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0CD00000

class DIVU(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'DIVU')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0D200000

class DIV(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'DIV')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0D300000

class REMU(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'REMU')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0D400000

class REM(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'REM')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0D500000

class LSL(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'LSL')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0E000000

class LSR(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'LSR')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0E100000

class ROL(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'ROL')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0E200000

class ROR(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'ROR')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0E300000

class ASL(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'ASL')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0E400000

class ASR(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'ASR')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0E500000

class FSUB(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'FSUB')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0F000000

class FADD(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'FADD')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x0F300000

class FMUL(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'FMUL')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x10100000

class FDIV(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'FDIV')
        self.register_a = register_1
        self.register_b = register_2
        self.register_c = register_3

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x11200000

class MVIL(instruction):

    def __init__(self, parrent, address, register, value):
        instruction.__init__(self, parrent, address, 'MVIL')
        self.register_c = register
        self.register_b = register
        self.value = value

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        value = checkSizeOfImmediate(self, 16, trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.value)[0])
        return self.regs | 0x12000000 | (value << 8)

class MVIH(instruction):

    def __init__(self, parrent, address, register, value):
        instruction.__init__(self, parrent, address, 'MVIH')
        self.register_c = register
        self.register_b = register
        self.value = value

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        value = checkSizeOfImmediate(self, 16, trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.value)[0])
        return self.regs | 0x13000000 | (value << 8)

class CALL(instruction):

    def __init__(self, parrent, address, call_address):
        instruction.__init__(self, parrent, address, 'CALL')
        self.call_address = call_address

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.call_address)
        self.relocation = result[1]
        call_address = checkSizeOfImmediate(self, 24, result[0])
        self.special = result[2]
        return self.regs | 0x80000000 | (call_address << 4)

class LD(instruction):

    def __init__(self, parrent, address, ld_address, register):
        instruction.__init__(self, parrent, address, 'LD')
        self.register_c = register
        self.ld_address = ld_address

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.ld_address)
        self.relocation = result[1]
        ld_address = checkSizeOfImmediate(self, 24, result[0])
        self.special = result[2]
        return self.regs | 0x90000000 | (ld_address << 4)

class ST(instruction):

    def __init__(self, parrent, address, register, st_address):
        instruction.__init__(self, parrent, address, 'ST')
        self.register_b = register
        self.st_address = st_address

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.st_address)
        self.relocation = result[1]
        st_address = checkSizeOfImmediate(self, 24, result[0])
        self.special = result[2]
        return self.regs | 0xA0000000 | (st_address & 0xF) | (((st_address & 0xFFFFF0) >> 4) << 8)

class BZ(instruction):

    def __init__(self, parrent, address, register, br_address):
        instruction.__init__(self, parrent, address, 'BZ')
        self.register_f = register
        self.br_address = br_address

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.br_address)
        self.relocation = result[1]
        br_address = checkSizeOfImmediate(self, 24, result[0])
        self.special = result[2]
        return self.regs | 0xB0000000 | ((br_address & 0xF00000) << 4) | (br_address & 0x0FFFFF)

class BNZ(instruction):

    def __init__(self, parrent, address, register, br_address):
        instruction.__init__(self, parrent, address, 'BNZ')
        self.register_f = register
        self.br_address = br_address

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.br_address)
        self.relocation = result[1]
        br_address = checkSizeOfImmediate(self, 24, result[0])
        self.special = result[2]
        return self.regs | 0xC0000000 | ((br_address & 0xF00000) << 4) | (br_address & 0x0FFFFF)

class MVIA(instruction):

    def __init__(self, parrent, address, register, operand):
        instruction.__init__(self, parrent, address, 'MVIA')
        self.register_c = register
        self.operand = operand

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.operand)
        self.relocation = result[1]
        operand = checkSizeOfImmediate(self, 24, result[0])
        self.special = result[2]
        return self.regs | 0xD0000000 | (operand << 4)

class SWI(instruction):

    def __init__(self, parrent, address):
        instruction.__init__(self, parrent, address, 'SWI')

    def translate(self, symbol_table, special_symbol_table):
        self.decodeRegs()
        return self.regs | 0x14000000
