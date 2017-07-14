#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  cpu.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz


import sys, numpy

class cpu():
    def __init__(self, readFunction, writeFunction, hRetiFunction):
        self.regs = [0]*16;
        self.writeFunction = writeFunction
        self.readFunction = readFunction
        self.hRetiFunction = hRetiFunction
        self.intVector = 0

    def reset(self):
        self.regs = [0]*16;

    def getRegByName(self, regName):
        if regName == "R0":
            return numpy.uint32(0)
        elif regName == "PC":
            return numpy.uint32(self.regs[15])
        elif regName == "SP":
            return numpy.uint32(self.regs[14])
        else:
            return numpy.uint32(self.regs[int(regName[1:])])

    def setRegByName(self, regName, value):
        if regName == "PC":
            self.regs[15] = numpy.uint32(value)
        elif regName == "SP":
            self.regs[14] = numpy.uint32(value)
        else:
            self.regs[int(regName[1:])] = numpy.uint32(value)

    def getRegByCode(self, regCode):
        if regCode == 0:
            return numpy.uint32(0)
        else:
            return numpy.uint32(self.regs[regCode])

    def setRegByCode(self, regCode, value):
        self.regs[regCode] = numpy.uint32(value)

    def readFromMem(self, address):
        return numpy.uint32(self.readFunction(address))

    def writeToMem(self, address, value):
        self.writeFunction(numpy.uint32(address), numpy.uint32(value))

    def executeInstruction(self, instructionWord):

        #change order of bits in instruction

        instructionWordBinary = bin(instructionWord).split("b")[1]
        instructionWordBinary = str.zfill(instructionWordBinary, 32)

        instructionWordBinaryTemp = ["0"]*32
        index = 0
        for item in instructionWordBinary:
            instructionWordBinaryTemp[31 - index] = str(item)
            index = index + 1

        instructionWordBinary = "".join(instructionWordBinaryTemp)

        #decoding itself

        opcode = None
        regA = None
        regB = None
        regC = None
        cons16 = None
        cons24 = None
        op = None

        if   instructionWordBinary[31] == '1':

            regA   = instructionWordBinary[24:28]
            cons24 = instructionWordBinary[0:24]

            if   instructionWordBinary[28:31] == "000" : opcode = "CALL"
            elif instructionWordBinary[28:31] == "100" : opcode = "LD"
            elif instructionWordBinary[28:31] == "010" : opcode = "ST"
            elif instructionWordBinary[28:31] == "110" : opcode = "BZ"
            elif instructionWordBinary[28:31] == "001" : opcode = "BNZ"
            elif instructionWordBinary[28:31] == "101" : opcode = "MVIA"
            else:
                print("Error! Should execute an undefined instruction <" + hex(instructionWord) + "> !")
                sys.exit(1)

        elif instructionWordBinary[28] == '1':

            regA   = instructionWordBinary[16:20]
            cons16 = instructionWordBinary[0:16]

            if   instructionWordBinary[20]    == '0'   : opcode = "MVIL"
            elif instructionWordBinary[20]    == '1'   : opcode = "MVIH"
            else:
                print("Error! Should execute an undefined instruction <" + hex(instructionWord) + "> !")
                sys.exit(1)

        elif instructionWordBinary[24] == '1':

            regA = instructionWordBinary[8:12]
            regB = instructionWordBinary[4:8]
            regC = instructionWordBinary[0:4]
            op   = instructionWordBinary[12:16]

            if   instructionWordBinary[16:20] == "0000": opcode = "CMP"
            elif instructionWordBinary[16:20] == "1000": opcode = "AND"
            elif instructionWordBinary[16:20] == "0100": opcode = "OR"
            elif instructionWordBinary[16:20] == "1100": opcode = "XOR"
            elif instructionWordBinary[16:20] == "0010": opcode = "ADD"
            elif instructionWordBinary[16:20] == "1010": opcode = "SUB"
            elif instructionWordBinary[16:20] == "0110": opcode = "INC"
            elif instructionWordBinary[16:20] == "1110": opcode = "DEC"
            elif instructionWordBinary[16:20] == "0001": opcode = "LSL"
            elif instructionWordBinary[16:20] == "1001": opcode = "LSR"
            elif instructionWordBinary[16:20] == "0101": opcode = "ROL"
            elif instructionWordBinary[16:20] == "1101": opcode = "ROR"
            else:
                print("Error! Should execute an undefined instruction <" + hex(instructionWord) + "> !")
                sys.exit(1)

        elif instructionWordBinary[16] == '1':

            regA = instructionWordBinary[4:8]
            regB = instructionWordBinary[0:4]

            if   instructionWordBinary[8:11]  == "000" : opcode = "LDI"
            elif instructionWordBinary[8:11]  == "100" : opcode = "STI"
            elif instructionWordBinary[8:11]  == "010" : opcode = "BZI"
            elif instructionWordBinary[8:11]  == "110" : opcode = "BNZI"
            elif instructionWordBinary[8:11]  == "001" : opcode = "MOV"
            else:
                print("Error! Should execute an undefined instruction <" + hex(instructionWord) + "> !")
                sys.exit(1)

        elif instructionWordBinary[12] == '1':

            regA = instructionWordBinary[0:4]

            if   instructionWordBinary[4:6]   == "00"  : opcode = "CALLI"
            elif instructionWordBinary[4:6]   == "10"  : opcode = "PUSH"
            elif instructionWordBinary[4:6]   == "01"  : opcode = "POP"
            else:
                print("Error! Should execute an undefined instruction <" + hex(instructionWord) + "> !")
                sys.exit(1)

        elif instructionWordBinary[8]  == '1':
            if   instructionWordBinary[0]     == '0'   : opcode = "RET"
            elif instructionWordBinary[0]     == '1'   : opcode = "RETI"
            else:
                print("Error! Should execute an undefined instruction <" + hex(instructionWord) + "> !")
                sys.exit(1)

        else:
            print("Error! Should execute an undefined instruction <" + hex(instructionWord) + "> !")
            sys.exit(1)

        # complete results

        if regA != None:
            regABuff = ["0"]*4
            index = 0
            for item in regA:
                regABuff[3 - index] = item
                index = index + 1
            regA = int("".join(regABuff), 2)

        if regB != None:
            regBBuff = ["0"]*4
            index = 0
            for item in regB:
                regBBuff[3 - index] = item
                index = index + 1
            regB = int("".join(regBBuff), 2)

        if regC != None:
            regCBuff = ["0"]*4
            index = 0
            for item in regC:
                regCBuff[3 - index] = item
                index = index + 1
            regC = int("".join(regCBuff), 2)

        if op != None:
            opBuff = ["0"]*4
            index = 0
            for item in op:
                opBuff[3 - index] = item
                index = index + 1
            op = int("".join(opBuff), 2)

        if cons16 != None:
            cons16Buff = ["0"]*16
            index = 0
            for item in cons16:
                cons16Buff[15 - index] = item
                index = index + 1
            cons16 = int("".join(cons16Buff), 2)

        if cons24 != None:
            cons24Buff = ["0"]*24
            index = 0
            for item in cons24:
                cons24Buff[23 - index] = item
                index = index + 1
            cons24 = int("".join(cons24Buff), 2)

        # execute

        if opcode == "RET":
            #increment SP
            self.setRegByName("SP", self.getRegByName("SP") + 1)
            #read from stack
            newPC = self.readFromMem(self.getRegByName("SP"))
            #store data into PC
            self.setRegByName("PC", newPC)
        elif opcode =="RETI":
            #increment SP
            self.setRegByName("SP", self.getRegByName("SP") + 1)
            #read from stack
            newPC = self.readFromMem(self.getRegByName("SP"))
            #store data into PC
            self.setRegByName("PC", newPC)
            #tell RETI to intControl
            self.hRetiFunction()
        elif opcode == "CALLI":
            #write PC to stack
            self.writeToMem(self.getRegByName("SP"), self.getRegByName("PC"))
            #decrement SP
            self.setRegByName("SP", self.getRegByName("SP") - 1)
            #load new value into PC
            self.setRegByName("PC", self.getRegByCode(regA))
        elif opcode == "PUSH":
            #specified reg into stack
            self.writeToMem(self.getRegByName("SP"), self.getRegByCode(regA))
            #decrement SP
            self.setRegByName("SP", self.getRegByName("SP") - 1)
        elif opcode == "POP":
            #increment SP
            self.setRegByName("SP", self.getRegByName("SP") + 1)
            #load data from stack
            self.setRegByCode(regA, self.readFromMem(self.getRegByName("SP")))
        elif opcode == "LDI":
            #read from memory
            data = self.readFromMem(self.getRegByCode(regB))
            #store into register
            self.setRegByCode(regA, data)
        elif opcode == "STI":
            #why am i writing this comments?
            # EDIT: BECAUSE I'M AN IDIOT!
            self.writeToMem(self.getRegByCode(regB), self.getRegByCode(regA))
        elif opcode == "BZI":
            value = self.getRegByCode(regA)
            if value == 0:
                self.setRegByName("PC", self.getRegByCode(regB))
        elif opcode == "BNZI":
            value = self.getRegByCode(regA)
            if value != 0:
                self.setRegByName("PC", self.getRegByCode(regB))
        elif opcode == "MOV":
            #move data
            self.setRegByCode(regA, self.getRegByCode(regB))
        elif opcode == "CMP":
            regBval = self.getRegByCode(regB)
            regCval = self.getRegByCode(regC)

            if   op == 0: # A == B
                if regBval == regCval:
                    self.setRegByCode(regA, 1)
                else:
                    self.setRegByCode(regA, 0)
            elif op == 1: # A != B
                if regBval != regCval:
                    self.setRegByCode(regA, 1)
                else:
                    self.setRegByCode(regA, 0)
            elif op == 2: # A <  B signed
                if numpy.int32(regBval) < numpy.int32(regCval):
                    self.setRegByCode(regA, 1)
                else:
                    self.setRegByCode(regA, 0)
            elif op == 3: # A <  B unsigned
                if numpy.uint32(regBval) < numpy.uint32(regCval):
                    self.setRegByCode(regA, 1)
                else:
                    self.setRegByCode(regA, 0)
            elif op == 4: # A >= B signed
                if numpy.int32(regBval) >= numpy.int32(regCval):
                    self.setRegByCode(regA, 1)
                else:
                    self.setRegByCode(regA, 0)
            elif op == 5: # A >= B unsigned
                if numpy.uint32(regBval) >= numpy.uint32(regCval):
                    self.setRegByCode(regA, 1)
                else:
                    self.setRegByCode(regA, 0)
            else:
                print "Have to compare but unknown condition is given."
                sys.exit(1)
        elif opcode == "AND":
            self.setRegByCode(regA, self.getRegByCode(regB) & self.getRegByCode(regC))
        elif opcode == "OR":
            self.setRegByCode(regA, self.getRegByCode(regB) | self.getRegByCode(regC))
        elif opcode == "XOR":
            self.setRegByCode(regA, self.getRegByCode(regB) ^ self.getRegByCode(regC))
        elif opcode == "ADD":
            self.setRegByCode(regA, self.getRegByCode(regB) + self.getRegByCode(regC))
        elif opcode == "SUB":
            self.setRegByCode(regA, self.getRegByCode(regB) - self.getRegByCode(regC))
        elif opcode == "INC":
            self.setRegByCode(regA, self.getRegByCode(regB) + 1)
        elif opcode == "DEC":
            self.setRegByCode(regA, self.getRegByCode(regB) - 1)
        elif opcode == "LSL":
            value = self.getRegByCode(regB)
            value = (value << op) & 0xFFFFFFFF
            self.setRegByCode(regA, value)
        elif opcode == "LSR":
            value = self.getRegByCode(regB)
            value = (value >> op) & 0xFFFFFFFF
            self.setRegByCode(regA, value)
        elif opcode == "ROL":
            value = self.getRegByCode(regB)
            value = ((value << op) | (value >> (32 - op))) & 0xFFFFFFFF
            self.setRegByCode(regA, value)
        elif opcode == "ROR":
            value = self.getRegByCode(regB)
            value = ((value >> op) | (value << (32 - op))) & 0xFFFFFFFF
            self.setRegByCode(regA, value)
        elif opcode == "MVIL":
            #get data from destination reg and cut them
            data = self.getRegByCode(regA) & 0xFFFF0000
            #add upper to bytes
            data = data | cons16
            #write back into reg
            self.setRegByCode(regA, data)
        elif opcode == "MVIH":
            #get data from destination reg and cut them
            data = self.getRegByCode(regA) & 0x0000FFFF
            #add upper to bytes
            data = data | (cons16 << 16)
            #write back into reg
            self.setRegByCode(regA, data)
        elif opcode == "CALL":
            #write PC to stack
            self.writeToMem(self.getRegByName("SP"), self.getRegByName("PC"))
            #decrement SP
            self.setRegByName("SP", self.getRegByName("SP") - 1)
            #load new value into PC
            self.setRegByName("PC", cons24)
        elif opcode == "LD":
            #read from memory
            data = self.readFromMem(cons24)
            #store into register
            self.setRegByCode(regA, data)
        elif opcode == "ST":
            self.writeToMem(cons24, self.getRegByCode(regA))
        elif opcode == "BZ":
            value = self.getRegByCode(regA)
            if value == 0:
                self.setRegByName("PC", cons24)
        elif opcode == "BNZ":
            value = self.getRegByCode(regA)
            if value != 0:
                self.setRegByName("PC", cons24)
        elif opcode == "MVIA":
            self.setRegByCode(regA, cons24)
        else:
            print("Error! Should execute an undefined instruction <" + hex(instructionWord) + "> !")
            sys.exit(1)

    def tick(self):
        instruction = numpy.uint32(self.readFromMem(self.getRegByName("PC")))
        self.setRegByName("PC", self.getRegByName("PC") + 1)
        self.executeInstruction(instruction)

        if self.intVector != 0:

            address = ((self.intVector - 1) * 2) + 0x10
            self.intVector = 0

            self.writeToMem(self.getRegByName("SP"), self.getRegByName("PC"))
            self.setRegByName("SP", self.getRegByName("SP") - 1)
            self.setRegByName("PC", address)

