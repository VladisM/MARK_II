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
    def __init__(self, readFunction, writeFunction, hRetiFunction, hInterrupt, name):
        self.regs = [0]*16;
        self.writeFunction = writeFunction
        self.readFunction = readFunction
        self.hRetiFunction = hRetiFunction
        self.intVector = 0
        self.intrq = False
        self.hInterrupt = hInterrupt
        self.__name__ = name

    def reset(self):
        self.regs = [0]*16;

    def getRegByName(self, regName):
        if regName == "R0":
            return numpy.uint32(0)
        elif regName == "PC":
            return numpy.uint32(self.regs[14])
        elif regName == "SP":
            return numpy.uint32(self.regs[15])
        else:
            return numpy.uint32(self.regs[int(regName[1:])])

    def setRegByName(self, regName, value):
        if regName == "PC":
            self.regs[14] = numpy.uint32(value)
        elif regName == "SP":
            self.regs[15] = numpy.uint32(value)
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

        instructionWordBinary = bin(instructionWord).split("b")[1]
        instructionWordBinary = str.zfill(instructionWordBinary, 32)

        instructionWordBinaryTemp = ["0"]*32
        index = 0
        for item in instructionWordBinary:
            instructionWordBinaryTemp[31 - index] = str(item)
            index = index + 1

        instructionWordBinary = "".join(instructionWordBinaryTemp)


        #decode opcode

        if instructionWordBinary[31] == "0":

            if   instructionWordBinary[24:29] == "10000": opcode = "RET"
            elif instructionWordBinary[24:29] == "01000": opcode = "RETI"
            elif instructionWordBinary[24:29] == "11000": opcode = "CALLI"
            elif instructionWordBinary[24:29] == "00100": opcode = "PUSH"
            elif instructionWordBinary[24:29] == "10100": opcode = "POP"
            elif instructionWordBinary[24:29] == "01100": opcode = "LDI"
            elif instructionWordBinary[24:29] == "11100": opcode = "STI"
            elif instructionWordBinary[24:29] == "00010": opcode = "BNZI"
            elif instructionWordBinary[24:29] == "10010": opcode = "BZI"
            elif instructionWordBinary[24:29] == "01010": opcode = "CMPI"
            elif instructionWordBinary[24:29] == "11010": opcode = "CMPF"
            elif instructionWordBinary[24:29] == "00110": opcode = "ALU"
            elif instructionWordBinary[24:29] == "10110": opcode = "ALU"
            elif instructionWordBinary[24:29] == "01110": opcode = "BARREL"
            elif instructionWordBinary[24:29] == "11110": opcode = "FPU"
            elif instructionWordBinary[24:29] == "00001": opcode = "FPU"
            elif instructionWordBinary[24:29] == "10001": opcode = "FPU"
            elif instructionWordBinary[24:29] == "01001": opcode = "MVIL"
            elif instructionWordBinary[24:29] == "11001": opcode = "MVIH"
            elif instructionWordBinary[24:29] == "00101": opcode = "SWI"
            else: opcode = None

        else:

            if   instructionWordBinary[28:31] == "000": opcode = "CALL"
            elif instructionWordBinary[28:31] == "100": opcode = "LD"
            elif instructionWordBinary[28:31] == "010": opcode = "ST"
            elif instructionWordBinary[28:31] == "110": opcode = "BZ"
            elif instructionWordBinary[28:31] == "001": opcode = "BNZ"
            elif instructionWordBinary[28:31] == "101": opcode = "MVIA"
            else: opcode = None

        regc = instructionWordBinary[0:4]
        regb = instructionWordBinary[4:8]
        rega = instructionWordBinary[8:12]
        regf = instructionWordBinary[20:24]
        cond = instructionWordBinary[20:24]
        aluop = instructionWordBinary[20:24]
        fpuop = instructionWordBinary[20:22]
        bar_dir = instructionWordBinary[20]
        bar_type = instructionWordBinary[21:23]

        regBuff = ["0"]*4

        index = 0
        for item in rega:
            regBuff[3 - index] = item
            index = index + 1
        rega = int("".join(regBuff), 2)

        index = 0
        for item in regb:
            regBuff[3 - index] = item
            index = index + 1
        regb = int("".join(regBuff), 2)

        index = 0
        for item in regc:
            regBuff[3 - index] = item
            index = index + 1
        regc = int("".join(regBuff), 2)

        index = 0
        for item in regf:
            regBuff[3 - index] = item
            index = index + 1
        regf = int("".join(regBuff), 2)

        index = 0
        for item in cond:
            regBuff[3 - index] = item
            index = index + 1
        cond = "".join(regBuff)

        index = 0
        for item in aluop:
            regBuff[3 - index] = item
            index = index + 1
        aluop = "".join(regBuff)

        if   cond == "0000": cond = "EQ"
        elif cond == "0001": cond = "G"
        elif cond == "0010": cond = "GE"
        elif cond == "0011": cond = "L"
        elif cond == "0100": cond = "LE"
        elif cond == "0101": cond = "NEQ"
        elif cond == "0110": cond = "EQ"
        elif cond == "0111": cond = "NEQ"
        elif cond == "1000": cond = "G"
        elif cond == "1001": cond = "GE"
        elif cond == "1010": cond = "L"
        elif cond == "1011": cond = "LE"
        elif cond == "1100": cond = "GU"
        elif cond == "1101": cond = "GEU"
        elif cond == "1110": cond = "LU"
        elif cond == "1111": cond = "LEU"

        if   aluop == "0000": aluop = "MULU"
        elif aluop == "0001": aluop = "MUL"
        elif aluop == "0010": aluop = "DIVU"
        elif aluop == "0011": aluop = "DIV"
        elif aluop == "0100": aluop = "REMU"
        elif aluop == "0101": aluop = "REM"
        elif aluop == "0110": aluop = "ADD"
        elif aluop == "0111": aluop = "SUB"
        elif aluop == "1000": aluop = "INC"
        elif aluop == "1001": aluop = "DEC"
        elif aluop == "1010": aluop = "AND"
        elif aluop == "1011": aluop = "OR"
        elif aluop == "1100": aluop = "XOR"
        elif aluop == "1101": aluop = "NOT"
        else: aluop = None

        if   bar_dir == "1": bar_dir = "R"
        elif bar_dir == "0": bar_dir = "L"

        if   bar_type == "00": bar_type = "LS"
        elif bar_type == "10": bar_type = "RO"
        else: bar_type = "AS"

        barop = bar_type + bar_dir

        if   fpuop == "00": fpuop = "FADD"
        elif fpuop == "10": fpuop = "FMUL"
        elif fpuop == "01": fpuop = "FDIV"
        elif fpuop == "11": fpuop = "FSUB"

        cons_mvil = instructionWordBinary[8:24]

        consBuff = ["0"]*16
        index = 0
        for item in cons_mvil:
            consBuff[15 - index] = item
            index = index + 1
        cons_mvil = int("".join(consBuff), 2)


        cons_mvia = instructionWordBinary[4:28]
        cons_st =  instructionWordBinary[0:4] + instructionWordBinary[8:28]
        cons_branch = instructionWordBinary[0:20] + instructionWordBinary[24:28]

        consBuff = ["0"]*24
        index = 0
        for item in cons_mvia:
            consBuff[23 - index] = item
            index = index + 1
        cons_mvia = int("".join(consBuff), 2)

        index = 0
        for item in cons_st:
            consBuff[23 - index] = item
            index = index + 1
        cons_st = int("".join(consBuff), 2)

        index = 0
        for item in cons_branch:
            consBuff[23 - index] = item
            index = index + 1
        cons_branch = int("".join(consBuff), 2)

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
            self.setRegByName("PC", self.getRegByCode(rega))

        elif opcode == "PUSH":
            #specified reg into stack
            self.writeToMem(self.getRegByName("SP"), self.getRegByCode(regb))
            #decrement SP
            self.setRegByName("SP", self.getRegByName("SP") - 1)

        elif opcode == "POP":
            #increment SP
            self.setRegByName("SP", self.getRegByName("SP") + 1)
            #load data from stack
            self.setRegByCode(regc, self.readFromMem(self.getRegByName("SP")))

        elif opcode == "LDI":
            #read from memory
            data = self.readFromMem(self.getRegByCode(rega))
            #store into register
            self.setRegByCode(regc, data)
        elif opcode == "STI":
            self.writeToMem(self.getRegByCode(rega), self.getRegByCode(regb))
        elif opcode == "BZI":
            value = self.getRegByCode(regf)
            if value == 0:
                self.setRegByName("PC", self.getRegByCode(rega))
        elif opcode == "BNZI":
            value = self.getRegByCode(regf)
            if value != 0:
                self.setRegByName("PC", self.getRegByCode(rega))
        elif opcode == "CMPI":
            regAval = self.getRegByCode(rega)
            regBval = self.getRegByCode(regb)

            if   cond == "EQ": # A == B
                if regAval == regBval:
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "NEQ": # A != B
                if regAval != regBval:
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "L": # A <  B signed
                if numpy.int32(regAval) < numpy.int32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "LU": # A <  B unsigned
                if numpy.uint32(regAval) < numpy.uint32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "LE": # A <= B signed
                if numpy.int32(regAval) <= numpy.int32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "LEU": # A <= B unsigned
                if numpy.uint32(regAval) <= numpy.uint32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "GE": # A >= B signed
                if numpy.int32(regAval) >= numpy.int32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "GEU": # A >= B unsigned
                if numpy.uint32(regAval) >= numpy.uint32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "G": # A > B signed
                if numpy.int32(regAval) > numpy.int32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "GU": # A > B unsigned
                if numpy.uint32(regAval) > numpy.uint32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            else:
                print "Have to compare but unknown condition is given."
                sys.exit(1)

        elif opcode == "CMPF":
            regAval = self.getRegByCode(rega)
            regBval = self.getRegByCode(regb)

            if   cond == "EQ": # A == B
                if numpy.float32(regAval) == numpy.float32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "NEQ": # A != B
                if numpy.float32(regAval) != numpy.float32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "L": # A <  B signed
                if numpy.float32(regAval) < numpy.float32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "LE": # A <= B signed
                if numpy.float32(regAval) <= numpy.float32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "GE": # A >= B signed
                if numpy.float32(regAval) >= numpy.float32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            elif cond == "G": # A > B signed
                if numpy.float32(regAval) > numpy.float32(regBval):
                    self.setRegByCode(regc, 1)
                else:
                    self.setRegByCode(regc, 0)
            else:
                print "Have to compare but unknown condition is given."
                sys.exit(1)

        elif opcode == "ALU":
            if   aluop == "MULU":
                self.setRegByCode(regc, numpy.uint32(self.getRegByCode(rega)) * numpy.uint32(self.getRegByCode(regb)))
            elif aluop == "MUL":
                self.setRegByCode(regc, numpy.int32(self.getRegByCode(rega)) * numpy.int32(self.getRegByCode(regb)))
            elif aluop == "DIVU":
                self.setRegByCode(regc, numpy.uint32(self.getRegByCode(rega)) / numpy.uint32(self.getRegByCode(regb)))
            elif aluop == "DIV":
                self.setRegByCode(regc, numpy.int32(self.getRegByCode(rega)) / numpy.int32(self.getRegByCode(regb)))
            elif aluop == "REMU":
                self.setRegByCode(regc, numpy.uint32(self.getRegByCode(rega)) % numpy.uint32(self.getRegByCode(regb)))
            elif aluop == "REM":
                self.setRegByCode(regc, numpy.int32(self.getRegByCode(rega)) % numpy.int32(self.getRegByCode(regb)))
            elif aluop == "ADD":
                self.setRegByCode(regc, self.getRegByCode(rega) + self.getRegByCode(regb))
            elif aluop == "SUB":
                self.setRegByCode(regc, self.getRegByCode(rega) - self.getRegByCode(regb))
            elif aluop == "INC":
                self.setRegByCode(regc, self.getRegByCode(rega) + 1)
            elif aluop == "DEC":
                self.setRegByCode(regc, self.getRegByCode(rega) - 1)
            elif aluop == "AND":
                self.setRegByCode(regc, self.getRegByCode(rega) & self.getRegByCode(regb))
            elif aluop == "OR":
                self.setRegByCode(regc, self.getRegByCode(rega) | self.getRegByCode(regb))
            elif aluop == "XOR":
                self.setRegByCode(regc, self.getRegByCode(rega) ^ self.getRegByCode(regb))
            elif aluop == "NOT":
                self.setRegByCode(regc, self.getRegByCode(rega) ^ 0xFFFFFFFF)
            else:
                print "Have to make computation but unknown operation is given."
                sys.exit(1)
        elif opcode == "FPU":

            if   fpuop == "FMUL":
                self.setRegByCode(regc, numpy.float32(self.getRegByCode(rega)) * numpy.float32(self.getRegByCode(regb)))
            elif fpuop == "FDIV":
                self.setRegByCode(regc, numpy.float32(self.getRegByCode(rega)) / numpy.float32(self.getRegByCode(regb)))
            elif fpuop == "FADD":
                self.setRegByCode(regc, numpy.float32(self.getRegByCode(rega)) + numpy.float32(self.getRegByCode(regb)))
            elif fpuop == "FSUB":
                self.setRegByCode(regc, numpy.float32(self.getRegByCode(rega)) - numpy.float32(self.getRegByCode(regb)))
            else:
                print "Have to make computation but unknown operation is given."
                sys.exit(1)

        elif opcode == "BARREL":

            if   barop == "LSL":
                value = self.getRegByCode(rega)
                value = (value << (self.getRegByCode(regb) & 0x1F)) & 0xFFFFFFFF
                self.setRegByCode(regc, value)
            elif barop == "LSR":
                value = self.getRegByCode(rega)
                value = (value >> (self.getRegByCode(regb) & 0x1F)) & 0xFFFFFFFF
                self.setRegByCode(regc, value)
            elif barop == "ROL":
                value = self.getRegByCode(rega)
                value = ((value << (self.getRegByCode(regb) & 0x1F)) | (value >> (32 - (self.getRegByCode(regb) & 0x1F)))) & 0xFFFFFFFF
                self.setRegByCode(regc, value)
            elif barop == "ROR":
                value = self.getRegByCode(rega)
                value = ((value >> (self.getRegByCode(regb) & 0x1F)) | (value << (32 - (self.getRegByCode(regb) & 0x1F)))) & 0xFFFFFFFF
                self.setRegByCode(regc, value)
            elif barop == "ASL":
                value = self.getRegByCode(rega)
                value = (value << (self.getRegByCode(regb) & 0x1F)) & 0xFFFFFFFF
                self.setRegByCode(regc, value)
            elif barop == "ASR":
                value = self.getRegByCode(rega)
                value = (value >> (self.getRegByCode(regb) & 0x1F)) & 0xFFFFFFFF
                self.setRegByCode(regc, value)
            else:
                print "Have to make computation but unknown operation is given."
                sys.exit(1)

        elif opcode == "MVIL":
            #get data from destination reg and cut them
            data = self.getRegByCode(regc) & 0xFFFF0000
            #add upper to bytes
            data = data | cons_mvil
            #write back into reg
            self.setRegByCode(regc, data)

        elif opcode == "MVIH":
            #get data from destination reg and cut them
            data = self.getRegByCode(regc) & 0x0000FFFF
            #add upper to bytes
            data = data | (cons_mvil << 16)
            #write back into reg
            self.setRegByCode(regc, data)

        elif opcode == "CALL":
            #write PC to stack
            self.writeToMem(self.getRegByName("SP"), self.getRegByName("PC"))
            #decrement SP
            self.setRegByName("SP", self.getRegByName("SP") - 1)
            #load new value into PC
            self.setRegByName("PC", cons_mvia)

        elif opcode == "LD":
            #read from memory
            data = self.readFromMem(cons_mvia)
            #store into register
            self.setRegByCode(regc, data)

        elif opcode == "ST":
            self.writeToMem(cons_st, self.getRegByCode(regb))

        elif opcode == "BZ":
            value = self.getRegByCode(regf)
            if value == 0:
                self.setRegByName("PC", cons_branch)

        elif opcode == "BNZ":
            value = self.getRegByCode(regf)
            if value != 0:
                self.setRegByName("PC", cons_branch)

        elif opcode == "MVIA":
            self.setRegByCode(regc, cons_mvia)

        elif opcode == "SWI":
            self.hInterrupt(self.__name__)

        else:
            print("Error! Should execute an undefined instruction <" + hex(instructionWord) + "> !")
            sys.exit(1)

    def tick(self):
        instruction = numpy.uint32(self.readFromMem(self.getRegByName("PC")))
        self.setRegByName("PC", self.getRegByName("PC") + 1)
        self.executeInstruction(instruction)

        if self.intrq == True:

            address = self.intVector
            self.intrq = False

            self.writeToMem(self.getRegByName("SP"), self.getRegByName("PC"))
            self.setRegByName("SP", self.getRegByName("SP") - 1)
            self.setRegByName("PC", address)

