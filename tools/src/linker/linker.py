#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  linker.py

import version

import sys, getopt

class symbol():
    #symbol - not so much usefull at all

    def __init__(self, name, value, mode):
        self.name = name
        self.value = value
        self.mode = mode

    def echo(self):
        print "Symbol '" + self.name + "' of type: '" + self.mode + "' with value: " + str(self.value)

class symbol_export(symbol):
    #one special symbol of type export

    def __init__(self, name, value):
        symbol.__init__(self, name, value, "export")

class symbol_import(symbol):
    #one special symbol of type import

    def __init__(self, name, id):
        symbol.__init__(self, name, None, "import")
        self.id = id

class symbol_table():
    #special symbol table

    def __init__(self):
        self.exports = []
        self.imports = []

    def echo(self):
        print "Export symbols: "
        for item in self.exports:
            item.echo()
        print "Import symbols: "
        for item in self.imports:
            item.echo()

    def append(self, line):
        line = line.split(':')
        if line[2] == "export":
            new_symbol = symbol_export(line[0], int(line[1]))
            self.exports.append(new_symbol)
        else:
            new_symbol = symbol_import(line[0], int(line[1]))
            self.imports.append(new_symbol)

class instruction():
    #instruction object, store one instruction in instruction table

    def __init__(self, address, value, relocation, special):
        self.address = int(address, 16)
        self.value = int(value, 16)

        if relocation == "True":
            self.relocation = True
        else:
            self.relocation = False

        if special == "True":
            self.special = True
        else:
            self.special = False

    def relocate(self, offset):

        self.address = self.address + offset

        if self.relocation == False:
            return;

        instruction_type = (self.value & 0xF0000000) >> 28
        instruction_argument = self.value & 0x00FFFFFF

        if instruction_type >= 8:
            instruction_argument = instruction_argument + offset
        else:
            print "I have to relocate instruction that don't have address in it opcode. Probably broken assembler!"
            print "Instruction word: " + hex(self.value) + " stored at address: "+ hex(self.address)
            sys.exit(1)

        if instruction_argument > 0x00FFFFFF:
            print "Address in opcode overflow after relocation! Put your code into another place!"
            print "Instruction word: " + hex(self.value) + " stored at address: "+ hex(self.address)
            sys.exit(1)

        self.value = (instruction_type <<  28) + (self.value & 0x0F000000) + instruction_argument

    def retarget(self, import_symbols_table):
        if self.special == False:
            return;

        instruction_type = (self.value & 0xF0000000) >> 28
        instruction_register = self.value & 0x0F000000
        instruction_argument = self.value & 0x00FFFFFF

        if instruction_type < 8:
            print "I read instruction marked as special relocation type, but it does not have address in obcode. Probably broken assembler!"
            print "Instruction word: " + hex(self.value) + " stored at address: "+ hex(self.address)
            sys.exit(1)

        found = False
        value = 0

        for item in import_symbols_table:
            if item.id == instruction_argument:
                found = True
                value = item.value
                break

        if found == False:
            print "I did not found inported label in import label table."
            sys.exit(1)

        self.value = (instruction_type << 28) + instruction_register + value

    def echo(self):
        print "Instruction at " + hex(self.address) + " instruction word: " + hex(self.value) + " relocation: " + str(self.relocation) + " special: " + str(self.special)

class instruction_table():
    #table of all instruction in object file

    def __init__(self):
        self.instructions = []

    def append(self, line):
        line = line.split(':')
        new_instruction = instruction(line[0], line[1], line[2], line[3])
        self.instructions.append(new_instruction)

    def echo(self):
        print "Instruction table: "
        for item in self.instructions:
            item.echo()

    def relocate(self, offset):
        for item in self.instructions:
            item.relocate(offset)

    def retarget(self, import_symbols_table):
        for item in self.instructions:
            item.retarget(import_symbols_table)

class output_buff_item():
    def __init__(self, address, value, relocation):
        self.address = address
        self.value = value
        self.relocation = relocation

class object_file():
    #one object file

    def __init__(self, filename):
        self.filename = filename
        self.symbols = symbol_table()
        self.instructions = instruction_table()
        self.size = 0

    def fill(self):
        try:
            f = file(self.filename, 'r')
        except:
            print "File " + self.filename + " is not readable."
            sys.exit(1)

        state = None

        for line in f:
            line = line.replace("\n", "")
            line = line.replace("\r", "")

            if line[0] != ".":
                if state == "symbols":
                    self.symbols.append(line)
                elif state == "text":
                    self.instructions.append(line)
                elif state == "size":
                    self.size = int(line)
            else:
                if line == ".text":
                    state = "text"
                    continue
                elif line == ".spec_symbols":
                    state = "symbols"
                    continue
                elif line == ".size":
                    state = "size"
                    continue

    def echo(self):
        print "Object file '" + self.filename + "' size: " + str(self.size)
        self.symbols.echo()
        self.instructions.echo()

class object_buffer():
    #here are all object files stored

    def __init__(self,name_list):
        self.files = []
        for name in name_list:
            new_object_file = object_file(name)
            new_object_file.fill()
            self.files.append(new_object_file)

    def echo(self):
        for object_file in self.files:
            object_file.echo()
            print "End of file " + object_file.filename

    def __relocate_instructions(self):
        offset = 0
        for file_item in self.files:
            file_item.instructions.relocate(offset)
            offset = offset + file_item.size

    def __relocate_exports(self):
        offset = 0
        for file_item in self.files:
            for label_item in file_item.symbols.exports:
                label_item.value = label_item.value + offset
            offset = offset + file_item.size

    def __get_exports(self):
        self.export_table = []

        for file_item in self.files:
            for label_item in file_item.symbols.exports:
                self.export_table.append(label_item)

    def __find_exported_label(self, key):

        found = False
        value = 0

        for item in self.export_table:
            if item.name == key:
                found = True
                value = item.value
                break
        return [found, value]

    def __solve_imports(self):

        for file_item in self.files:
            for label_item in file_item.symbols.imports:

                name = label_item.name
                found, value = self.__find_exported_label(name)

                if found == "False":
                    print "Label '" +  name + "' is not exported! Can not link files! Exiting!"
                    sys.exit(1)

                label_item.value = value

        for file_item in self.files:
            file_item.instructions.retarget(file_item.symbols.imports)

    def __generate_output_buff(self):

        self.output_buff = []

        for file_item in self.files:
            for instruction_item in file_item.instructions.instructions:

                new_item = output_buff_item(instruction_item.address, instruction_item.value, instruction_item.relocation)

                for mem_item in self.output_buff:
                    if mem_item.address == new_item.address:
                        print "Overlaping instructions in linker!"
                        sys.exit(1)

                self.output_buff.append(new_item)

    def link(self):
        self.__relocate_instructions()
        self.__relocate_exports()
        self.__get_exports()
        self.__solve_imports()
        self.__generate_output_buff()

    def generate_output_file(self, filename):

        f = None
        try:
            f = file(filename, "w")
        except:
            print "Can't open output file for writing!"
            sys.exit(1)

        for item in self.output_buff:
            f.write(hex(item.address))
            f.write(":")
            f.write(hex(item.value))
            f.write(":")
            f.write(str(item.relocation))
            f.write("\n")

        f.close()

def usage():
    print """
Example usage: linker example1.o example2.o

        This is linker for MARK II Assembler. This program take list of object
    files as arguments and link them together into one load module.

Arguments:
    -h --help           Print this help.
    -o <file>           Output LDM file name. If not specified, name of first
                        object file will be used.
       --version        Print version number and exit.
"""

def get_args():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:", ["help", "version"])
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)

    output_file = None

    for option, value in opts:
        if option in ("-h", "--help"):
            usage()
            sys.exit()
        elif option == "-o":
            print value
            output_file = value
        elif option == "--version":
            print "Linker for MARK-II CPU " + version.version
            sys.exit(1)
        else:
            sys.exit(1)

    input_filenames = []

    for arg in args:
        input_filenames.append(arg)

    if len(input_filenames) == 0:
        print "Please specify input object files."
        sys.exit(1)

    if output_file == None:
        output_file = (input_filenames[0].split('.')[0]).split('/')[-1] + ".ldm"

    return output_file, input_filenames

def main():

    output_file, input_files =  get_args()

    buff = object_buffer(input_files)
    buff.link()
    buff.generate_output_file(output_file)

    return 0

if __name__ == '__main__':
    main()
    sys.exit()
