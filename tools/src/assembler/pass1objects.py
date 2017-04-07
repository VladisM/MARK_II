#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  pass1objects.py

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

    def echo(self):
        print "Binary blob at address " + hex(self.address) + " cantains data: " + hex(self.data)

    def translate(self, symbol_table, special_symbol_table):
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.data)
        return checkSizeOfImmediate(self, 32, result[0])

class instruction(item):

    def __init__(self, parrent, address, opcode):
        item.__init__(self, parrent, address)
        self.opcode = opcode
        self.relocation = False
        self.special = False

    def echo(self):
        print "Instruction '" + self.opcode + "' at address: "+ hex(self.address) + " from : " + self.parrent.fileName + "@" + str(self.parrent.lineNumber) + " with relocation: " + str(self.relocation) + " special: " + str(self.special)

class RET(instruction):

    def __init__(self, parrent, address):
        instruction.__init__(self, parrent, address, 'RET')

    def translate(self, symbol_table, special_symbol_table):
        return 0x00000100


class RETI(instruction):

    def __init__(self, parrent, address):
        instruction.__init__(self, parrent, address, 'RETI')

    def translate(self, symbol_table, special_symbol_table):
        return 0x00000101

class CALLI(instruction):

    def __init__(self, parrent, address, register):
        instruction.__init__(self, parrent, address, 'CALLI')
        self.register_a = register

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        return 0x00001000 + reg_a


class PUSH(instruction):

    def __init__(self, parrent, address, register):
        instruction.__init__(self, parrent, address, 'PUSH')
        self.register_a = register

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        return 0x00001010 + reg_a

class POP(instruction):

    def __init__(self, parrent, address, register):
        instruction.__init__(self, parrent, address, 'POP')
        self.register_a = register

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        return 0x00001020 + reg_a


class LDI(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'LDI')
        self.register_a = register_2
        self.register_b = register_1

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        return 0x00010000 + (reg_a << 4) + reg_b

class STI(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'STI')
        self.register_a = register_1
        self.register_b = register_2

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        return 0x00010100 + (reg_a << 4) + reg_b


class BZI(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'BZI')
        self.register_a = register_1
        self.register_b = register_2

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        return 0x00010200 + (reg_a << 4) + reg_b

class BNZI(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'BNZI')
        self.register_a = register_1
        self.register_b = register_2

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        return 0x00010300 + (reg_a << 4) + reg_b

class MOV(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'MOV')
        self.register_a = register_2
        self.register_b = register_1

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        return 0x00010400 + (reg_a << 4) + reg_b

class CMP(instruction):

    def __init__(self, parrent, address, comparison, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'AND')
        self.register_a = register_3
        self.register_b = register_1
        self.register_c = register_2
        self.comparison = comparison

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        reg_c = decodeRegName(self, self.register_c)
        comp = decodeComparison(self, self.comparison)
        return 0x01000000 + (comp << 12) + (reg_a << 8) + (reg_b << 4) + reg_c

class AND(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'AND')
        self.register_a = register_3
        self.register_b = register_1
        self.register_c = register_2

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        reg_c = decodeRegName(self, self.register_c)
        return 0x01010000 + (reg_a << 8) + (reg_b << 4) + reg_c

class OR(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'OR')
        self.register_a = register_3
        self.register_b = register_1
        self.register_c = register_2

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        reg_c = decodeRegName(self, self.register_c)
        return 0x01020000 + (reg_a << 8) + (reg_b << 4) + reg_c

class XOR(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'XOR')
        self.register_a = register_3
        self.register_b = register_1
        self.register_c = register_2

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        reg_c = decodeRegName(self, self.register_c)
        return 0x01030000 + (reg_a << 8) + (reg_b << 4) + reg_c

class ADD(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'ADD')
        self.register_a = register_3
        self.register_b = register_1
        self.register_c = register_2

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        reg_c = decodeRegName(self, self.register_c)
        return 0x01040000 + (reg_a << 8) + (reg_b << 4) + reg_c

class SUB(instruction):

    def __init__(self, parrent, address, register_1, register_2, register_3):
        instruction.__init__(self, parrent, address, 'SUB')
        self.register_a = register_3
        self.register_b = register_1
        self.register_c = register_2

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        reg_c = decodeRegName(self, self.register_c)
        return 0x01050000 + (reg_a << 8) + (reg_b << 4) + reg_c

class INC(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'INC')
        self.register_a = register_2
        self.register_b = register_1

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        return 0x01060000 + (reg_a << 8) + (reg_b << 4)

class DEC(instruction):

    def __init__(self, parrent, address, register_1, register_2):
        instruction.__init__(self, parrent, address, 'DEC')
        self.register_a = register_2
        self.register_b = register_1

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        return 0x01070000 + (reg_a << 8) + (reg_b << 4)

class LSL(instruction):

    def __init__(self, parrent, address, distance, register_1, register_2):
        instruction.__init__(self, parrent, address, 'LSL')
        self.distance = distance
        self.register_a = register_2
        self.register_b = register_1

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.distance)
        dist = checkSizeOfImmediate(self, 4, result[0])
        return 0x01080000 + (dist << 12) + (reg_a << 8) + (reg_b << 4)

class LSR(instruction):

    def __init__(self, parrent, address, distance, register_1, register_2):
        instruction.__init__(self, parrent, address, 'LSR')
        self.distance = distance
        self.register_a = register_2
        self.register_b = register_1

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.distance)
        dist = checkSizeOfImmediate(self, 4, result[0])
        return 0x01090000 + (dist << 12) + (reg_a << 8) + (reg_b << 4)

class ROL(instruction):

    def __init__(self, parrent, address, distance, register_1, register_2):
        instruction.__init__(self, parrent, address, 'ROL')
        self.distance = distance
        self.register_a = register_2
        self.register_b = register_1

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.distance)
        dist = checkSizeOfImmediate(self, 4, result[0])
        return 0x010A0000 + (dist << 12) + (reg_a << 8) + (reg_b << 4)


class ROR(instruction):

    def __init__(self, parrent, address, distance, register_1, register_2):
        instruction.__init__(self, parrent, address, 'ROR')
        self.distance = distance
        self.register_a = register_2
        self.register_b = register_1

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        reg_b = decodeRegName(self, self.register_b)
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.distance)
        dist = checkSizeOfImmediate(self, 4, result[0])
        return 0x010B0000 + (dist << 12) + (reg_a << 8) + (reg_b << 4)


class MVIL(instruction):

    def __init__(self, parrent, address, register, value):
        instruction.__init__(self, parrent, address, 'MVIL')
        self.register_a = register
        self.value = value

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        value = checkSizeOfImmediate(self, 16, trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.value)[0])
        return 0x10000000 + (reg_a << 16) + value

class MVIH(instruction):

    def __init__(self, parrent, address, register, value):
        instruction.__init__(self, parrent, address, 'MVIH')
        self.register_a = register
        self.value = value

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        value = checkSizeOfImmediate(self, 16, trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.value)[0])
        return 0x10100000 + (reg_a << 16) + value

class CALL(instruction):

    def __init__(self, parrent, address, call_address):
        instruction.__init__(self, parrent, address, 'CALL')
        self.call_address = call_address

    def translate(self, symbol_table, special_symbol_table):
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.call_address)
        self.relocation = result[1]
        call_address = checkSizeOfImmediate(self, 24, result[0])
        self.special = result[2]
        return 0x80000000 + call_address


class LD(instruction):

    def __init__(self, parrent, address, ld_address, register):
        instruction.__init__(self, parrent, address, 'LD')
        self.register_a = register
        self.ld_address = ld_address

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.ld_address)
        self.relocation = result[1]
        ld_address = checkSizeOfImmediate(self, 24, result[0])
        self.special = result[2]
        return 0x90000000 + (reg_a << 24) + ld_address

class ST(instruction):

    def __init__(self, parrent, address, register, st_address):
        instruction.__init__(self, parrent, address, 'ST')
        self.register_a = register
        self.st_address = st_address

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.st_address)
        self.relocation = result[1]
        st_address = checkSizeOfImmediate(self, 24, result[0])
        self.special = result[2]
        return 0xA0000000 + (reg_a << 24) + st_address

class BZ(instruction):

    def __init__(self, parrent, address, register, br_address):
        instruction.__init__(self, parrent, address, 'BZ')
        self.register_a = register
        self.br_address = br_address

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.br_address)
        self.relocation = result[1]
        br_address = checkSizeOfImmediate(self, 24, result[0])
        self.special = result[2]
        return 0xB0000000 + (reg_a << 24) + br_address

class BNZ(instruction):

    def __init__(self, parrent, address, register, br_address):
        instruction.__init__(self, parrent, address, 'BNZ')
        self.register_a = register
        self.br_address = br_address

    def translate(self, symbol_table, special_symbol_table):
        reg_a = decodeRegName(self, self.register_a)
        result = trySolveImmediateOperand(self, symbol_table, special_symbol_table, self.br_address)
        self.relocation = result[1]
        br_address = checkSizeOfImmediate(self, 24, result[0])
        self.special = result[2]
        return 0xC0000000 + (reg_a << 24) + br_address
