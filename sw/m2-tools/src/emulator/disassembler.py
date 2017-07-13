# Some code taken from disassembler used in emulator.
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz

def convertRegToName(reg):
    if reg == 14:
        return "SP"
    elif reg == 15:
        return "PC"
    else:
        return "R" + str(reg)

def decodeInstruction(instructionWord):

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
        return "CALLI\t" + convertRegToName(regA)
    elif opcode == "PUSH":
        return "PUSH \t" + convertRegToName(regA)
    elif opcode == "POP":
        return "PUSH \t" + convertRegToName(regA)
    elif opcode == "LDI":
        return "LDI  \t" +  convertRegToName(regB) + " " + convertRegToName(regA)
    elif opcode == "STI":
        return "STI  \t" +  convertRegToName(regA) + " " + convertRegToName(regB)
    elif opcode == "BZI":
        return "BZI  \t" +  convertRegToName(regA) + " " + convertRegToName(regB)
    elif opcode == "BNZI":
        return "BNZI \t" +  convertRegToName(regA) + " " + convertRegToName(regB)
    elif opcode == "MOV":
        return "MOV  \t" +  convertRegToName(regB) + " " + convertRegToName(regA)
    elif opcode == "CMP":
        if   op == 0:
            return "CMP  \tEQ " +  convertRegToName(regB) + " " + convertRegToName(regC) + " " + convertRegToName(regA)
        elif op == 1:
            return "CMP  \tNEQ " +  convertRegToName(regB) + " " + convertRegToName(regC) + " " + convertRegToName(regA)
        elif op == 2:
            return "CMP  \tL " +  convertRegToName(regB) + " " + convertRegToName(regC) + " " + convertRegToName(regA)
        elif op == 3:
            return "CMP  \tLU " +  convertRegToName(regB) + " " + convertRegToName(regC) + " " + convertRegToName(regA)
        elif op == 4:
            return "CMP  \tGE " +  convertRegToName(regB) + " " + convertRegToName(regC) + " " + convertRegToName(regA)
        elif op == 5:
            return "CMP  \tGEU " +  convertRegToName(regB) + " " + convertRegToName(regC) + " " + convertRegToName(regA)
        else:
            return None
    elif opcode == "AND":
        return "AND  \t" +  convertRegToName(regB) + " " + convertRegToName(regC) + " " + convertRegToName(regA)
    elif opcode == "OR":
        return "OR   \t" +  convertRegToName(regB) + " " + convertRegToName(regC) + " " + convertRegToName(regA)
    elif opcode == "XOR":
        return "XOR  \t" +  convertRegToName(regB) + " " + convertRegToName(regC) + " " + convertRegToName(regA)
    elif opcode == "ADD":
        return "ADD  \t" +  convertRegToName(regB) + " " + convertRegToName(regC) + " " + convertRegToName(regA)
    elif opcode == "SUB":
        return "SUB  \t" +  convertRegToName(regB) + " " + convertRegToName(regC) + " " + convertRegToName(regA)
    elif opcode == "INC":
        return "INC  \t" +  convertRegToName(regB) + " " + convertRegToName(regA)
    elif opcode == "DEC":
        return "DEC  \t" +  convertRegToName(regB) + " " + convertRegToName(regA)
    elif opcode == "LSL":
        return "LSL  \t" +  str(op) + " " + convertRegToName(regB) + " " + convertRegToName(regA)
    elif opcode == "LSR":
        return "LSR  \t" +  str(op) + " " + convertRegToName(regB) + " " + convertRegToName(regA)
    elif opcode == "ROL":
        return "ROL  \t" +  str(op) + " " + convertRegToName(regB) + " " + convertRegToName(regA)
    elif opcode == "ROR":
        return "ROR  \t" +  str(op) + " " + convertRegToName(regB) + " " + convertRegToName(regA)
    elif opcode == "MVIL":
        return "MVIL \t" + convertRegToName(regA) + " " +  hex(cons16)
    elif opcode == "MVIH":
        return "MVIH \t" +  convertRegToName(regA) + " " +  hex(cons16)
    elif opcode == "CALL":
        return "CALL \t" + hex(cons24)
    elif opcode == "LD":
        return "LD   \t" + hex(cons24) + " " + convertRegToName(regA)
    elif opcode == "ST":
        return "ST   \t" +  convertRegToName(regA) + " " + hex(cons24)
    elif opcode == "BZ":
        return "BZ   \t" + convertRegToName(regA) + " " +  hex(cons24)
    elif opcode == "BNZ":
        return "BNZ  \t" + convertRegToName(regA) + " " +  hex(cons24)
    elif opcode == "MVIA":
        return "MVIA \t" + convertRegToName(regA) + " " +  hex(cons24)
    else:
        return None
