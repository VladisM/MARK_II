#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  assembler.py

import version

import tokenizer, sys, getopt, common

import pass1objects as p1o

class special_symbol():

    def __init__(self, label, parrent, mode):
        self.label = label
        self.parrent = parrent
        self.mode = mode
        self.relocation = True
        self.address = ""

class symbol():

    def __init__(self, label, address, parrent, relocation):
        self.label = label
        self.address = address
        self.parrent = parrent
        self.relocation = relocation

class p2buffer_item():

    def __init__(self, address, value, parrent, relocation, special):
        self.address = address
        self.value = value
        self.parrent = parrent
        self.relocation = relocation
        self.special = special

class assembler():

    def __init__(self, fileName):
        self.mainFileName = fileName
        self.t = None

        self.symbol_table = []
        self.special_symbol_table = []

        self.pass1_buffer = []
        self.pass2_buffer = []

        self.top_address = 0

    def pass0(self):

        #read input file and parse it (also invoke preprocesor)
        self.t = tokenizer.tokenizer()
        self.t.parse(self.mainFileName)

    def pass1(self):

        location_counter = 0

        for token in self.t.parser_buffer:

            if token.__name__ == "label":
                #if there is an label, store it into symbol table, but take care about multiple declaration

                for item in self.symbol_table:
                    if item.label == token.labelName:
                        print "Error! Multiple label declaration: '" + item.label + "'"
                        print item.label + " from " + item.parrent.fileName + "@" + str(item.parrent.lineNumber) + " conflicts with " + token.label + " from " + token.fileName + "@" + str(token.lineNumber)
                        sys.exit(1)

                new_symbol = symbol(token.labelName, location_counter, token, True)
                self.symbol_table.append(new_symbol)

            elif token.__name__ == "pseudoInstruction":

                if token.opcode == "ORG":
                    if len(token.operands) != 1:
                        print "Invalid operands count at: " + token.fileName + "@" + str(token.lineNumber) + ". PseudoOp .ORG expected 1 argument, " + str(len(token.operands)) + " given."
                        sys.exit(1)

                    address = token.operands[0]

                    if type(address) != int:
                        print "Invalid operand type at: " + token.fileName + "@" + str(token.lineNumber) + ". PseudoOp .ORG expected <type 'int'> argument, " + str(type(address)) + " given."
                        sys.exit(1)

                    location_counter = address

                elif token.opcode == "CONS":
                    if len(token.operands) != 2:
                        print "Invalid operands count at: " + token.fileName + "@" + str(token.lineNumber) + ". PseudoOp .CONS expected 2 arguments, " + str(len(token.operands)) + " given."
                        sys.exit(1)

                    name = token.operands[0]
                    value = token.operands[1]

                    if type(name) != str:
                        print "Invalid operand type at: " + token.fileName + "@" + str(token.lineNumber) + ". PseudoOp .CONS expected <type 'str'> as <name> argument, " + str(type(name)) + " given."
                        sys.exit(1)

                    if type(value) != int:
                        print "Invalid operand type at: " + token.fileName + "@" + str(token.lineNumber) + ". PseudoOp .CONS expected <type 'int'> as <value> argument, " + str(type(value)) + " given."
                        sys.exit(1)

                    for item in self.symbol_table:
                        if item.label == name:
                            print "Error! Multiple symbol declaration: '" + item.label + "'"
                            print item.label + " from " + item.parrent.fileName + "@" + str(item.parrent.lineNumber) + " conflicts with " + name + " from " + token.fileName + "@" + str(token.lineNumber)
                            sys.exit(1)

                    new_symbol = symbol(name, value, token, False)
                    self.symbol_table.append(new_symbol)

                elif token.opcode == "DAT":
                    if len(token.operands) == 0:
                        print "Invalid operands count at: " + token.fileName + "@" + str(token.lineNumber) + ". PseudoOp .DAT expected at least 1 argument, " + str(len(token.operands)) + " given."
                        sys.exit(1)

                    for operand in token.operands:
                        if type(operand) != int:
                            print "Invalid operand type at: " + token.fileName + "@" + str(token.lineNumber) + ". PseudoOp .DAT expected <type 'int'> as arguments, " + str(type(operand)) + " given."
                            sys.exit(1)
                        new_blob = p1o.blob(token, location_counter, operand)

                        self.pass1_buffer.append(new_blob)
                        location_counter = location_counter + 1

                elif token.opcode == "DS":
                    if len(token.operands) != 1:
                        print "Invalid operands count at: " + token.fileName + "@" + str(token.lineNumber) + ". PseudoOp .DS expected 1 argument, " + str(len(token.operands)) + " given."
                        sys.exit(1)

                    size = token.operands[0]

                    if type(size) != int:
                        print "Invalid operand type at: " + token.fileName + "@" + str(token.lineNumber) + ". PseudoOp .DS expected <type 'int'> as <size> argument, " + str(type(value)) + " given."
                        sys.exit(1)

                    location_counter = location_counter + size

                elif token.opcode == "EXPORT":

                    if len(token.operands) == 0:
                        print "At least one operand excepted at: " + token.fileName + "@" + str(token.lineNumber) + "." + str(len(token.operands)) + " given."
                        sys.exit(1)

                    for label in token.operands:

                        if type(label) != str:
                            print "Error! Operand of EXPORT pseudo instruction at " + token.fileName + "@" + str(token.lineNumber) + " have to be string but it is not."
                            sys.exit(1)

                        new_spec_symbol = special_symbol(label, token, "export")
                        self.special_symbol_table.append(new_spec_symbol)

                elif token.opcode == "IMPORT":

                    if len(token.operands) == 0:
                        print "At least one operand excepted at: " + token.fileName + "@" + str(token.lineNumber) + "." + str(len(token.operands)) + " given."
                        sys.exit(1)

                    for label in token.operands:

                        if type(label) != str:
                            print "Error! Operand of IMPORT pseudo instruction at " + token.fileName + "@" + str(token.lineNumber) + " have to be string but it is not."
                            sys.exit(1)

                        new_spec_symbol = special_symbol(label, token, "import")
                        self.special_symbol_table.append(new_spec_symbol)

                elif token.opcode == "MVI":
                    if len(token.operands) != 2:
                        print "Invalid operands count at: " + token.fileName + "@" + str(token.lineNumber) + ". PseudoOp .MVI expected 2 argument, " + str(len(token.operands)) + " given."
                        sys.exit(1)

                    reg = token.operands[0]
                    value = token.operands[1]

                    value_low = value & 0x0000FFFF
                    value_high = (value & 0xFFFF0000) >> 16

                    new_instruction = p1o.MVIL(token, location_counter, reg, value_low)
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                    new_instruction = p1o.MVIH(token, location_counter, reg, value_high)
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                else:
                    print "Error! I found unknown pseudoInstruction at " + token.fileName + "@" + token.lineNumber + ". File contain: '" + token.lineString + "'."
                    sys.exit(1)

            elif token.__name__ == "instruction":
                if token.opcode == "RET":

                    arguments_count = 0
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.RET(token, location_counter)
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "RETI":

                    arguments_count = 0
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.RETI(token, location_counter)
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "CALLI":

                    arguments_count = 1
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.CALLI(token, location_counter, token.operands[0])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "PUSH":

                    arguments_count = 1
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.PUSH(token, location_counter, token.operands[0])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "POP":

                    arguments_count = 1
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.POP(token, location_counter, token.operands[0])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "LDI":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.LDI(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "STI":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.STI(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "BZI":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.BZI(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "BNZI":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.BNZI(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "MOV":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.MOV(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "CMP":

                    arguments_count = 4
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.CMP(token, location_counter, token.operands[0], token.operands[1], token.operands[2], token.operands[3])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "AND":

                    arguments_count = 3
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.AND(token, location_counter, token.operands[0], token.operands[1], token.operands[2])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "OR":

                    arguments_count = 3
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.OR(token, location_counter, token.operands[0], token.operands[1], token.operands[2])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "XOR":

                    arguments_count = 3
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.XOR(token, location_counter, token.operands[0], token.operands[1], token.operands[2])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "ADD":

                    arguments_count = 3
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.ADD(token, location_counter, token.operands[0], token.operands[1], token.operands[2])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "SUB":

                    arguments_count = 3
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.SUB(token, location_counter, token.operands[0], token.operands[1], token.operands[2])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "INC":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.INC(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "DEC":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.DEC(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "LSL":

                    arguments_count = 3
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.LSL(token, location_counter, token.operands[0], token.operands[1], token.operands[2])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "LSR":

                    arguments_count = 3
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.LSR(token, location_counter, token.operands[0], token.operands[1], token.operands[2])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "ROL":

                    arguments_count = 3
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.ROL(token, location_counter, token.operands[0], token.operands[1], token.operands[2])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "ROR":

                    arguments_count = 3
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.ROR(token, location_counter, token.operands[0], token.operands[1], token.operands[2])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "MVIL":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.MVIL(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "MVIH":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.MVIH(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "CALL":

                    arguments_count = 1
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.CALL(token, location_counter, token.operands[0])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "LD":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.LD(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "ST":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.ST(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "BZ":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.BZ(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "BNZ":

                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.BNZ(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                elif token.opcode == "MVIA":
                    arguments_count = 2
                    arguments_given = len(token.operands)

                    if arguments_count != arguments_given:
                        print "Error in instruction '" + token.opcode + "' at " + token.fileName + "@" + str(token.lineNumber) + ", unexpected arugments. Instruction take " + str(arguments_count) + " arguments but " + str(arguments_given) + " are given."
                        sys.exit(1)

                    new_instruction = p1o.MVIA(token, location_counter, token.operands[0], token.operands[1])
                    self.pass1_buffer.append(new_instruction)
                    location_counter = location_counter + 1

                else:
                    print "Error! Found unknown instruction '" + token.opcode + "' at: '" + token.fileName + "@" + str(token.lineNumber)
                    sys.exit(1);

            else:
                print "Error! Found unexpected object in tokenized buffer. Maybe broken tokenizer?"
                sys.exit(1)

    def pass2(self):

        import_label_counter = 0

        for item in self.special_symbol_table:
            if item.mode == "export":
                found, value, relocation = common.findSymbol(self.symbol_table, item.label)
                if found == False:
                    print "Trying to export symbol: " + item.label + " from " + item.parrent.fileName + "@" + str(item.parrent.lineNumber) + " but it does not exist!"
                    sys.exit(1)
                else:
                    item.address = value
            else:
                item.address = import_label_counter
                import_label_counter = import_label_counter + 1

        for item in self.pass1_buffer:
            address = item.address

            if address > self.top_address:
                self.top_address = address

            for mem_item in self.pass2_buffer:
                if mem_item.address == address:
                    print "Instruction '" + mem_item.parrent.opcode + "' from " + mem_item.parrent.parrent.fileName + "@" + str(mem_item.parrent.parrent.lineNumber) + " conflicts with instruction '" + item.opcode + "' from " + item.parrent.fileName + "@" + str(item.parrent.lineNumber)
                    sys.exit(1)

            value = item.translate(self.symbol_table, self.special_symbol_table)
            relocation = item.relocation
            special = item.special

            new_item = p2buffer_item(address, value, item, relocation, special)
            self.pass2_buffer.append(new_item)

class file_gen():

    def make_object(self, p2buff, specbuff, top_address, outFileName):
        f = None
        try:
            f = file(outFileName, "w")
        except:
            print "Can't open output file for writing!"
            sys.exit(1)

        f.write(".size\n")
        f.write(str(top_address + 1))
        f.write("\n")

        f.write(".spec_symbols\n")

        for item in specbuff:
            f.write(item.label)
            f.write(":")
            f.write(str(item.address))
            f.write(":")
            f.write(item.mode)
            f.write("\n")

        f.write(".text\n")

        for item in p2buff:
            f.write(hex(item.address))
            f.write(":")
            f.write(hex(item.value))
            f.write(":")
            f.write(str(item.relocation))
            f.write(":")
            f.write(str(item.special))
            f.write("\n")

        f.close()

    def make_ldm(self, p2buff, outFileName):

        f = None
        try:
            f = file(outFileName, "w")
        except:
            print "Can't open output file for writing!"
            sys.exit(1)

        for item in p2buff:
            f.write(hex(item.address))
            f.write(":")
            f.write(hex(item.value))
            f.write(":")
            f.write(str(item.relocation))
            f.write("\n")

        f.close()

def usage():
    print """
Example usage: assembler.py main.asm

        This is two pass assembler for MARK II CPU. For informations about
    MARK II please see: https://github.com/VladisM/MARK_II-SoC/

Arguments:
    -h --help           Print this help.
    -o --output         Output object file name.
       --skip-linker    Generate relocatable loader module instead object file.
                        Can be used for skipping linker if linking is not
                        needed.
       --version        Print version number and exit.
    """

def get_args():

    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:", ["help", "output=", "skip-linker", "version"])
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)

    input_file = None
    output_file = None
    skip_linker = False

    for option, value in opts:
        if option in ("-h", "--help"):
            usage()
            sys.exit()
        elif option in ("-o", "--output"):
            output_file = value
        elif option == "--skip-linker":
            skip_linker = True
        elif option == "--version":
            print "Assembler for MARK-II CPU " + version.version
            sys.exit(1)
        else:
            print "Unrecognized option " + option
            print "Type 'assembler.py -h' for more informations."
            sys.exit(1)

    if len(args) > 1:
        print "Too much argument given!"
        sys.exit(1)
    elif len(args) == 0:
        print "Name of input file is not specified!"
        sys.exit(1)

    input_file = args[0]

    if output_file == None:
        if skip_linker == False:
            output_file = (input_file.split('.')[0]).split('/')[-1] + ".o"
        else:
            output_file = (input_file.split('.')[0]).split('/')[-1] + ".ldm"

    return input_file, output_file, skip_linker

def main():

    input_file, output_file, skip_linker = get_args()

    a = assembler(input_file)

    a.pass0()
    a.pass1()
    a.pass2()

    fg = file_gen()

    if skip_linker == False:
        fg.make_object(a.pass2_buffer, a.special_symbol_table, a.top_address, output_file)
    else:
        fg.make_ldm(a.pass2_buffer, output_file)

    sys.exit()

if __name__ == '__main__':
    main()
