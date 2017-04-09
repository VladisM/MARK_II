#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  tokenizer.py

import getopt, os, sys, common

class item():

    __name__ = "item"

    def __init__(self, lineNumber, fileName, lineString, tokens):
        self.lineNumber = lineNumber
        self.fileName = fileName
        self.lineString = lineString
        self.tokens = tokens

class label(item):

    __name__ = "label"

    def __init__(self, lineNumber, fileName, lineString, tokens, labelName):
        item.__init__(self, lineNumber, fileName, lineString, tokens)
        self.labelName = labelName

class pseudoInstruction(item):

    __name__ = "pseudoInstruction"

    def __init__(self, lineNumber, fileName, lineString, tokens, opcode, operands):
        item.__init__(self, lineNumber, fileName, lineString, tokens)
        self.opcode = opcode
        self.operands = operands

class instruction(item):

    __name__ = "instruction"

    def __init__(self, lineNumber, fileName, lineString, tokens, opcode, operands):
        item.__init__(self, lineNumber, fileName, lineString, tokens)
        self.opcode = opcode
        self.operands = operands

class macro():
    def __init__(self, name, arguments):
        self.name = name
        self.buff = []
        self.arguments = arguments

    def invoke(self, parser_buffer, given_args):
        print "Invoking an macro is not implemented yet! exiting"
        sys.exit(1)
        #TODO: Přidat kód k rozvinutí makra, nahrazovat argumenty při rozvíjení

class tokenizer():

    def __init__(self, debug):
        self.debug = debug
        self.parser_buffer = []
        self.preprocesor_symbols = []
        self.macro_table = []
        self.macro_solving = False

    def parse(self, p):
        self.load_file(p)
        self.solve_items()

    def load_file(self, p):

        #open file
        try:
            f = file(p, "r")
        except:
            print("Can't open input file " + p + " for reading.")
            sys.exit(1)

        #get some info lines number are stored in buffer, also file name
        #usefull info when there is an error during asembly
        line_counter = 0
        file_name = f.name

        pre_if_false = 0

        for line in f:

            line_counter = line_counter + 1

            #original source code line will be stored too
            lineString = line
            lineString = lineString.replace("\n", "")
            lineString = lineString.replace("\r", "")

            #remove  all mess from line
            line = line.replace("\t", "")
            line = line.replace(",", "")
            line = line.replace("\n", "")
            line = line.replace("\r", "")
            line = line.lstrip()
            line = line.partition(";")
            line = line[0]
            line = line.split(" ")

            if line == [""]: continue

            line_for_save = []

            #take all non empty parts of line
            for part in line:
                if part != "": line_for_save.append(part)

            #if whole line is empty, skip to next line
            if len(line_for_save) == 0: continue

            #if somebody write label on same line with instruction; this will split it
            if line_for_save[0].find(":") == len(line[0]) - 1:

                if pre_if_false != 0: continue #this "if" is for conditional assembly, it can be found later too

                if self.macro_solving == True:
                    print "Labels in macros are not supported!"
                    sys.exit(1)

                #create new item object and store it into buffer
                new_item = item(line_counter, file_name, lineString, [line_for_save[0]])

                #accept labels only outside of macros
                if self.macro_solving == False:
                    self.parser_buffer.append(new_item)

                #rest of line store back to line_for_save for additional processing
                new_line = []
                for i in range(1, len(line_for_save)):
                    new_line.append(line_for_save[i])
                line_for_save = new_line

            #if there was an line only with label, line_for_save may be empty; if so skip to next line
            if len(line_for_save) == 0: continue

            #take symbols from source file
            if line_for_save[0] == "#define":
                if pre_if_false == 0:
                    self.preprocesor_symbols.append(line_for_save[1])
                    continue

            #conditional assembly if symbol is defined, following code will be assembled
            elif line_for_save[0] == "#ifdef":
                if pre_if_false == 0:
                    condition = line_for_save[1]

                    found = False
                    for symbol in self.preprocesor_symbols:
                        if symbol == condition:
                            found = True
                            continue
                    if found == False:
                        pre_if_false = 1

                    continue

            elif line_for_save[0] == "#ifndef":
                if pre_if_false == 0:
                    condition = line_for_save[1]

                    found = False
                    for symbol in self.preprocesor_symbols:
                        if symbol == condition:
                            found = True
                            continue
                    if found == True:
                        pre_if_false = 1

                    continue

            #this take care about end of conditional assembly region
            elif line_for_save[0] == "#endif":
                pre_if_false = 0
                continue

            #magic for include!
            elif line_for_save[0] == "#include":
                if pre_if_false == 0:
                    filename = line_for_save[1]
                    self.load_file(filename)        #recursion!

            #found macro definition, start recording
            elif line_for_save[0] == "#macro":

                if pre_if_false != 0: continue

                if self.macro_solving == True:
                    print "Nested macros are not supported!"
                    sys.exit(1)

                elif len(line_for_save) == 1:
                    print "Missing name for new macro"
                    sys.exit(1)

                macro_name = line_for_save[1]
                arguments_list  = line_for_save[2:]

                self.new_macro = macro(macro_name, arguments_list)

                self.macro_solving = True

            #found end of macro, store it in macro table
            elif line_for_save[0] == "#endmacro":

                if pre_if_false != 0: continue

                for macro_item in self.macro_table:
                    if macro_item.name == self.new_macro.name:
                        print "Macro '" + self.new_macro.name + "' is already defined. "
                        sys.exit(1)

                if self.macro_solving == False:
                    print "Found #endmacro without opening an macro."
                    sys.exit(1)

                self.macro_table.append(self.new_macro)
                self.new_macro = None

                self.macro_solving = False

            #invoke macro
            elif line_for_save[0].find("$") == 0:
                found = False
                for macro_item in self.macro_table:
                    if macro_item.name != line_for_save[0].split("$")[1]: continue
                    found = True
                    given_args = line_for_save[1:]
                    macro_item.invoke(self.parser_buffer, given_args)

                if found == False:
                    print "Macro is not found in macro table!"
                    sys.exit(1)


            else:
                #there should be nice and clean instruction to store it into buffer
                #so create an new item and store it
                if pre_if_false != 0: continue

                new_item = item(line_counter, file_name, lineString, line_for_save)

                if self.macro_solving == False:
                    self.parser_buffer.append(new_item)
                else:
                    self.new_macro.buff.append(new_item)

    def solve_items(self):

        #create temporary buffer, take item from buffer, decide about type,
        #and paste item here with additional informations; after all, simply
        #copy temp_buff into parsing_buffer
        temp_buff = []

        for itemx in self.parser_buffer:
            #label found
            if itemx.tokens[0].find(":") == len(itemx.tokens[0]) - 1:

                new_label = label(itemx.lineNumber, itemx.fileName, itemx.lineString, itemx.tokens, itemx.tokens[0].split(':')[0])
                temp_buff.append(new_label)

            #pseudoinstruction found
            elif itemx.tokens[0].find(".") == 0:

                operands = itemx.tokens[1 : len(itemx.tokens)]

                #try to convert operand into numbers (we try all operands)
                pointer = 0
                for operand in operands:
                    result = common.tryConvertNumber(operand)
                    if result[0] == True: operands[pointer] = result[1]
                    pointer = pointer + 1

                new_pseudo_op = pseudoInstruction(itemx.lineNumber, itemx.fileName, itemx.lineString, itemx.tokens, itemx.tokens[0].split('.')[1], operands)
                temp_buff.append(new_pseudo_op)

            #everything else should be instructions
            else :

                operands = itemx.tokens[1 : len(itemx.tokens)]

                #try to convert operand into numbers (we try all operands)
                pointer = 0
                for operand in operands:
                    result = common.tryConvertNumber(operand)
                    if result[0] == True: operands[pointer] = result[1]
                    pointer = pointer + 1

                new_instruction = instruction(itemx.lineNumber, itemx.fileName, itemx.lineString, itemx.tokens, itemx.tokens[0], operands)
                temp_buff.append(new_instruction)

        #copy buffer
        self.parser_buffer = temp_buff
