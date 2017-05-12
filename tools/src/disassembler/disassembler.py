#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, math, version, getopt

class disassembler:
    def __init__(self):
        self.disassembled = []
        self.mem = []

    def loadFile(self, fileName):
        self.loadeif(fileName)

    def loadeif(self, fileName):
        try:
            f = file(fileName, "r")
        except:
            print "Error! Can't open input file <" + fileName + "> for reading!"
            sys.exit(1)

        for line in f:
            line.replace("\n", "")
            line.replace("\r", "")
            line.replace(" ", "")
            self.mem.append(int(line.upper(), 16))

        f.close()

    def convertRegToName(self, reg):
        if reg == 14:
            return "SP"
        elif reg == 15:
            return "PC"
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

        elif instructionWordBinary[28] == '1':

            regA   = instructionWordBinary[16:20]
            cons16 = instructionWordBinary[0:16]

            if   instructionWordBinary[20]    == '0'   : opcode = "MVIL"
            elif instructionWordBinary[20]    == '1'   : opcode = "MVIH"

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

        elif instructionWordBinary[16] == '1':

            regA = instructionWordBinary[4:8]
            regB = instructionWordBinary[0:4]

            if   instructionWordBinary[8:11]  == "000" : opcode = "LDI"
            elif instructionWordBinary[8:11]  == "100" : opcode = "STI"
            elif instructionWordBinary[8:11]  == "010" : opcode = "BZI"
            elif instructionWordBinary[8:11]  == "110" : opcode = "BNZI"
            elif instructionWordBinary[8:11]  == "001" : opcode = "MOV"

        elif instructionWordBinary[12] == '1':

            regA = instructionWordBinary[0:4]

            if   instructionWordBinary[4:6]   == "00"  : opcode = "CALLI"
            elif instructionWordBinary[4:6]   == "10"  : opcode = "PUSH"
            elif instructionWordBinary[4:6]   == "01"  : opcode = "POP"

        elif instructionWordBinary[8]  == '1':
            if   instructionWordBinary[0]     == '0'   : opcode = "RET"
            elif instructionWordBinary[0]     == '1'   : opcode = "RETI"

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


        if opcode == "RET":
            return "RET  "
        elif opcode =="RETI":
            return "RETI "
        elif opcode == "CALLI":
            return "CALLI\t" + self.convertRegToName(regA)
        elif opcode == "PUSH":
            return "PUSH \t" + self.convertRegToName(regA)
        elif opcode == "POP":
            return "PUSH \t" + self.convertRegToName(regA)
        elif opcode == "LDI":
            return "LDI  \t" +  self.convertRegToName(regB) + " " + self.convertRegToName(regA)
        elif opcode == "STI":
            return "STI  \t" +  self.convertRegToName(regA) + " " + self.convertRegToName(regB)
        elif opcode == "BZI":
            return "BZI  \t" +  self.convertRegToName(regA) + " " + self.convertRegToName(regB)
        elif opcode == "BNZI":
            return "BNZI \t" +  self.convertRegToName(regA) + " " + self.convertRegToName(regB)
        elif opcode == "MOV":
            return "MOV  \t" +  self.convertRegToName(regB) + " " + self.convertRegToName(regA)
        elif opcode == "CMP":
            if   op == 0:
                return "CMP  \tEQ " +  self.convertRegToName(regB) + " " + self.convertRegToName(regC) + " " + self.convertRegToName(regA)
            elif op == 1:
                return "CMP  \tNEQ " +  self.convertRegToName(regB) + " " + self.convertRegToName(regC) + " " + self.convertRegToName(regA)
            elif op == 2:
                return "CMP  \tL " +  self.convertRegToName(regB) + " " + self.convertRegToName(regC) + " " + self.convertRegToName(regA)
            elif op == 3:
                return "CMP  \tLU " +  self.convertRegToName(regB) + " " + self.convertRegToName(regC) + " " + self.convertRegToName(regA)
            elif op == 4:
                return "CMP  \tGE " +  self.convertRegToName(regB) + " " + self.convertRegToName(regC) + " " + self.convertRegToName(regA)
            elif op == 5:
                return "CMP  \tGEU " +  self.convertRegToName(regB) + " " + self.convertRegToName(regC) + " " + self.convertRegToName(regA)
            else:
                return None
        elif opcode == "AND":
            return "AND  \t" +  self.convertRegToName(regB) + " " + self.convertRegToName(regC) + " " + self.convertRegToName(regA)
        elif opcode == "OR":
            return "OR   \t" +  self.convertRegToName(regB) + " " + self.convertRegToName(regC) + " " + self.convertRegToName(regA)
        elif opcode == "XOR":
            return "XOR  \t" +  self.convertRegToName(regB) + " " + self.convertRegToName(regC) + " " + self.convertRegToName(regA)
        elif opcode == "ADD":
            return "ADD  \t" +  self.convertRegToName(regB) + " " + self.convertRegToName(regC) + " " + self.convertRegToName(regA)
        elif opcode == "SUB":
            return "SUB  \t" +  self.convertRegToName(regB) + " " + self.convertRegToName(regC) + " " + self.convertRegToName(regA)
        elif opcode == "INC":
            return "INC  \t" +  self.convertRegToName(regB) + " " + self.convertRegToName(regA)
        elif opcode == "DEC":
            return "DEC  \t" +  self.convertRegToName(regB) + " " + self.convertRegToName(regA)
        elif opcode == "LSL":
            return "LSL  \t" +  str(op) + " " + self.convertRegToName(regB) + " " + self.convertRegToName(regA)
        elif opcode == "LSR":
            return "LSR  \t" +  str(op) + " " + self.convertRegToName(regB) + " " + self.convertRegToName(regA)
        elif opcode == "ROL":
            return "ROL  \t" +  str(op) + " " + self.convertRegToName(regB) + " " + self.convertRegToName(regA)
        elif opcode == "ROR":
            return "ROR  \t" +  str(op) + " " + self.convertRegToName(regB) + " " + self.convertRegToName(regA)
        elif opcode == "MVIL":
            return "MVIL \t" + self.convertRegToName(regA) + " " +  hex(cons16)
        elif opcode == "MVIH":
            return "MVIH \t" +  self.convertRegToName(regA) + " " +  hex(cons16)
        elif opcode == "CALL":
            return "CALL \t" + hex(cons24)
        elif opcode == "LD":
            return "LD   \t" + hex(cons24) + " " + self.convertRegToName(regA)
        elif opcode == "ST":
            return "ST   \t" +  self.convertRegToName(regA) + " " + hex(cons24)
        elif opcode == "BZ":
            return "BZ   \t" + self.convertRegToName(regA) + " " +  hex(cons24)
        elif opcode == "BNZ":
            return "BNZ  \t" + self.convertRegToName(regA) + " " +  hex(cons24)
        elif opcode == "MVIA":
            return "MVIA \t" + self.convertRegToName(regA) + " " +  hex(cons24)
        else:
            return None

    def disassemble(self, filename):
        #load file
        self.loadFile(filename)

        #translate all instruction from file
        for instruction in self.mem:

            result = self.decodeInstruction(instruction)

            if result == None:  #if translate fail - store value in hex form
                self.disassembled.append(hex(instruction))
            else:
                self.disassembled.append(result)

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
            if line == "0x0":
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
Example usage: disassembler uart.ldm

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
