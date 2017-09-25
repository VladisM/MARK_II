#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# disassembler.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz

import sys, math, version, getopt, mif

class disassembler:
    def __init__(self):
        self.disassembled = []
        self.mem = []

    def loadFile(self, fileName):

        miffile = mif.mif(mif.READ, fileName)

        if miffile.read() == mif.OK:
            for item in miffile.outBuff:
                self.mem.append(item.value)
        else:
            print "Error in disassebler! Can't can't read input file <" + fileName + ">!"
            print miffile.errmsg
            sys.exit(1)


    def convertRegToName(self, reg):
        if reg == 14:
            return "PC"
        elif reg == 15:
            return "SP"
        else:
            return "R" + str(reg)

    def decodeInstruction(self, instructionWord):

        #change order of bits in instruction

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
        cons_st = instructionWordBinary[8:28] + instructionWordBinary[0:4]
        cons_branch = instructionWordBinary[24:28] + instructionWordBinary[0:20]

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

        regc = self.convertRegToName(regc)
        regb = self.convertRegToName(regb)
        rega = self.convertRegToName(rega)
        regf = self.convertRegToName(regf)


        if   opcode == "RET":
            return "RET"
        elif opcode == "RETI":
            return "RETI"
        elif opcode == "CALLI":
            return "CALLI\t" + rega
        elif opcode == "PUSH":
            return "PUSH\t" + regb
        elif opcode == "POP":
            return "POP\t" + regc
        elif opcode == "LDI":
            return "LDI\t" + rega + " " + regc
        elif opcode == "STI":
            return "STI\t" + regb + " " + rega
        elif opcode == "BNZI":
            return "BNZI\t" + regf + " " + rega
        elif opcode == "BZI":
            return "BZI\t" + regf + " " + rega
        elif opcode == "CMPI":
            return "CMPI\t" + cond + " " + rega + " " + regb + " " + regc
        elif opcode == "CMPF":
            return "CMPF\t" + cond + " " + rega + " " + regb + " " + regc
        elif opcode == "ALU":

            if   aluop == "MULU":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "MUL":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "DIVU":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "DIV":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "REMU":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "REM":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "ADD":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "SUB":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "INC":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "DEC":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "AND":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "OR":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "XOR":
                return aluop + "\t" + rega + " " + regb + " " + regc
            elif aluop == "NOT":
                return aluop + "\t" + rega + " " + regb + " " + regc
            else:
                return None

        elif opcode == "BARREL":
            return bar_type + bar_dir + "\t" + rega + " " + regb + " " + regc
        elif opcode == "FPU":
            return fpuop + "\t" + rega + " " + regb + " " + regc
        elif opcode == "MVIL":
            return "MVIL\t" + regc + " " + hex(cons_mvil)
        elif opcode == "MVIH":
            return "MVIH\t" + regc + " " + hex(cons_mvil)
        elif opcode == "SWI":
            return "SWI"
        elif opcode == "CALL":
            return "CALL\t" + hex(cons_mvia)
        elif opcode == "LD":
            return "LD\t" + hex(cons_mvia) + " " + regc
        elif opcode == "ST":
            return "ST\t" + regb + " " + hex(cons_st)
        elif opcode == "BZ":
            return "BZ\t" + regf + " " + hex(cons_branch)
        elif opcode == "BNZ":
            return "BNZ\t" + regf + " " + hex(cons_branch)
        elif opcode == "MVIA":
            return "MVIA\t" + regc + " " + hex(cons_mvia)
        else:
            return None


    def disassemble(self, filename):
        #load file
        self.loadFile(filename)

        #translate all instruction from file
        for instruction in self.mem:

            result = self.decodeInstruction(instruction)

            if result == None:  #if translate fail - store value in hex form
                self.disassembled.append("0x" + ((hex(instruction).split("0x"))[1]).zfill(8))
            else:
                self.disassembled.append("0x" + ((hex(instruction).split("0x"))[1]).zfill(8) + "\t" + result)

    def createOutput(self, filename):

        #try open output file for writing
        try:
            of = file(filename, "w")
        except:
            print "Can't open output file for writing!"
            sys.exit(1)

        #solve how much digits we need for address
        zerocount = int(math.ceil(math.log(len(self.disassembled), 2)/4.0))

        lineNumber = 0  #this count lines -> address so
        nulls = 0

        for line in self.disassembled:

            #count empty lines (0 in memory)
            if line == "0x00000000":
                nulls = nulls + 1
            else:
                nulls = 0

            #if we have 2 empty line, print \n, otherwise, if we have less than 2 lines, print data on line
            #otherwise print nothing
            if nulls == 2:
                of.write("\n")
            else:
                if nulls < 2:
                    of.write("0x" + ((hex(lineNumber).split('x'))[1]).zfill(zerocount) + "\t")
                    of.write(line)
                    of.write("\n")
                else:
                    pass

            #line counter, hack for counting memory addreses
            lineNumber = lineNumber + 1

        of.close()

def usage():
    print """
Example usage: disassembler uart.mif

        Simple disassembler for MARK-II, for more information please see:
    https://github.com/VladisM/MARK_II/

Arguments:
    -h --help           Print this help.
    -o --output         Output file name.
       --version        Print version number and exit.
    """

def get_args():

    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:", ["help", "output=","version"])
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)

    input_file = None
    output_file = None

    for option, value in opts:
        if option in ("-h", "--help"):
            usage()
            sys.exit()
        elif option in ("-o", "--output"):
            output_file = value
        elif option == "--version":
            print "Disassembler for MARK-II CPU " + version.version
            sys.exit(1)
        else:
            print "Unrecognized option " + option
            print "Type 'disassembler -h' for more informations."
            sys.exit(1)

    if len(args) > 1:
        print "Too much argument given!"
        sys.exit(1)
    elif len(args) == 0:
        print "Name of input file is not specified!"
        sys.exit(1)

    input_file = args[0]

    if output_file == None:
        output_file = (input_file.split('.')[0]).split('/')[-1] + ".txt"

    return input_file, output_file

def main():
    inputFile, outputFile = get_args()
    ds = disassembler()
    ds.disassemble(inputFile)
    ds.createOutput(outputFile)

if __name__ == "__main__":
    main()
