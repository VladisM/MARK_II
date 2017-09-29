#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  tokenizer.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz


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

    instance = 0

    def __init__(self, name, arguments):
        self.name = name
        self.buff = []
        self.arguments = arguments

    def find_arg_value(self, given_args, key):
        counter = 0
        found = False
        for item in self.arguments:
            if item == key:
                found = True
                break
            else:
                counter = counter + 1

        if found == False:
            return found, None

        return found, given_args[counter]

    def create_local_symbol_table(self):
        self.temp_symbol_table = []

        #try to find all labels in macro
        for line in self.buff:
            if line.tokens[0].find(":") == len(line.tokens[0]) - 1:
                original_value = (line.tokens[0].split(":"))[0]
                new_value = original_value + "_" + str(self.instance)
                self.temp_symbol_table.append([original_value, new_value])

    def invoke(self, parser_buffer, given_args, invoke_line, invoke_file):

        self.instance = self.instance + 1

        if len(given_args) != len(self.arguments):
            print "Error! Invalid arguments count when invoking macro " + self.name + " at " + invoke_file + "@" + str(invoke_line)
            sys.exit(1)

        for line in self.buff:

            new_line = []

            if line.tokens[0].find(":") == len(line.tokens[0]) - 1:
                for temp_symbol in self.temp_symbol_table:
                    if (line.tokens[0].split(":"))[0] == temp_symbol[0]:
                        new_line.append(temp_symbol[1] + ":")

            for line_token in line.tokens:
                found_arg, value_arg = self.find_arg_value(given_args, line_token)

                found_label = False
                value_label = None

                for temp_symbol in self.temp_symbol_table:
                    if line_token == temp_symbol[0]:
                        found_label = True
                        value_label = temp_symbol[1]
                        break

                if found_arg == True:
                    new_line.append(value_arg)
                elif found_label == True:
                    new_line.append(value_label)
                else:
                    new_line.append(line_token)

            new_item = item(line.lineNumber, line.fileName, line.lineString, new_line)
            parser_buffer.append(new_item)


class tokenizer():

    def __init__(self):
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
            print("Error! Can't open input file " + p + " for reading.")
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

                #create new item object and store it into buffer

                new_item = item(line_counter, file_name, lineString, [line_for_save[0]])

                if self.macro_solving == False:
                    self.parser_buffer.append(new_item)
                else:
                    self.new_macro.buff.append(new_item)

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

            #conditional assembly if symbol is defined, following code will be assembled
            elif line_for_save[0] == "#ifdef":

                condition = line_for_save[1]

                found = False
                for symbol in self.preprocesor_symbols:
                    if symbol == condition:
                        found = True
                        continue
                if found == False:
                    pre_if_false = pre_if_false + 1

            elif line_for_save[0] == "#ifndef":

                condition = line_for_save[1]

                found = False
                for symbol in self.preprocesor_symbols:
                    if symbol == condition:
                        found = True
                        continue
                if found == True:
                    pre_if_false = pre_if_false + 1

            #this take care about end of conditional assembly region
            elif line_for_save[0] == "#endif":
                if pre_if_false > 0:
                    pre_if_false = pre_if_false - 1

            #magic for include!
            elif line_for_save[0] == "#include":
                if pre_if_false == 0:
                    filename = line_for_save[1]
                    self.load_file(filename)        #recursion!

            #found macro definition, start recording
            elif line_for_save[0] == "#macro":

                if pre_if_false != 0: continue

                if self.macro_solving == True:
                    print "Error in " + file_name + "@" + str(line_counter) + ". Nested macro definitions are not supported!"
                    sys.exit(1)

                elif len(line_for_save) == 1:
                    print "Error in " + file_name + "@" + str(line_counter) + ". Missing name for new macro!"
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
                        print "Error! Macro '" + self.new_macro.name + "' is already defined. "
                        sys.exit(1)

                if self.macro_solving == False:
                    print "Error in " + file_name + "@" + str(line_counter) + ". Found #endmacro without opening an macro."
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
                    macro_item.create_local_symbol_table()
                    macro_item.invoke(self.parser_buffer, given_args, line_counter, file_name)

                if found == False:
                    print "Error in " + file_name + "@" + str(line_counter) + ". Trying to invoke macro " + line_for_save[0].split("$")[1] + " but definition is not found!"
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
