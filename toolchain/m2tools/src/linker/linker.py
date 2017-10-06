#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  linker.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz

import version

import sys, getopt, os, glob

class symbol():
    #symbol - not so much usefull at all
    def __init__(self, name, value, mode):
        self.name = name
        self.value = value
        self.mode = mode

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
        
        if (self.relocation == True) and (self.special == True):
            return;
        
        instruction_type = (self.value & 0xF0000000) >> 28

        instruction_argument = self.__get_argument()

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

        self.__set_argument(instruction_argument)

    def __set_argument(self, instruction_argument):
        instruction_type = (self.value & 0xF0000000) >> 28
        if instruction_type == 8:
            instruction_argument = instruction_argument << 4
            self.value = instruction_argument | (self.value & 0xF000000F)

        elif instruction_type == 9:
            instruction_argument = instruction_argument << 4
            self.value = instruction_argument | (self.value & 0xF000000F)

        elif instruction_type == 10:
            instruction_argument = ((instruction_argument & 0x00FFFFF0) << 4) | (instruction_argument & 0x0000000F)
            self.value = instruction_argument | (self.value & 0xF00000F0)

        elif instruction_type == 11:
            instruction_argument = ((instruction_argument & 0x00F00000) << 4) | (instruction_argument & 0x000FFFFF)
            self.value = instruction_argument | (self.value & 0xF0F00000)

        elif instruction_type == 12:
            instruction_argument = ((instruction_argument & 0x00F00000) << 4) | (instruction_argument & 0x000FFFFF)
            self.value = instruction_argument | (self.value & 0xF0F00000)

        elif instruction_type == 13:
            instruction_argument = instruction_argument << 4
            self.value = instruction_argument | (self.value & 0xF000000F)

        else:
            print "Linker doesn't not able recognize instruction!"
            print "Instruction word: " + hex(self.value) + " stored at address: "+ hex(self.address)
            sys.exit(1)

    def __get_argument(self):
        instruction_type = (self.value & 0xF0000000) >> 28
        if instruction_type == 8:
            instruction_argument = (self.value & 0x0FFFFFF0) >> 4
        elif instruction_type == 9:
            instruction_argument = (self.value & 0x0FFFFFF0) >> 4
        elif instruction_type == 10:
            instruction_argument = ((self.value & 0x0FFFFF00) >> 4) | (self.value & 0x0000000F)
        elif instruction_type == 11:
            instruction_argument = ((self.value & 0x0F000000) >> 4) | (self.value & 0x000FFFFF)
        elif instruction_type == 12:
            instruction_argument = ((self.value & 0x0F000000) >> 4) | (self.value & 0x000FFFFF)
        elif instruction_type == 13:
            instruction_argument = (self.value & 0x0FFFFFF0) >> 4
        else:
            print "Linker doesn't not able recognize instruction!"
            print "Instruction word: " + hex(self.value) + " stored at address: "+ hex(self.address)
            sys.exit(1)
        return instruction_argument


    def retarget(self, import_symbols_table):
        if self.special == False:
            return;

        instruction_type = (self.value & 0xF0000000) >> 28

        instruction_argument = self.__get_argument()

        if instruction_type < 8:
            print "I read instruction marked as special relocation type, but it does not have address in opcode. Probably broken assembler!"
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
            print "I did not found imported label in import label table."
            sys.exit(1)

        self.__set_argument(value)

class instruction_table():
    #table of all instruction in object file

    def __init__(self):
        self.instructions = []

    def append(self, line):
        line = line.split(':')
        new_instruction = instruction(line[0], line[1], line[2], line[3])
        self.instructions.append(new_instruction)

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

class object_buffer():
    #here are all object files stored

    def __init__(self,name_list, libs):
        self.files = []
        self.missing_exports = []
        self.libs = libs
        for name in name_list:
            new_object_file = object_file(name)
            new_object_file.fill()
            self.files.append(new_object_file)

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

    def __find_imports(self):
        
        for file_item in self.files:
            for label_item in file_item.symbols.imports:

                name = label_item.name
                found, value = self.__find_exported_label(name)

                if found == False:
                    self.missing_exports.append(name)
    
    #browse libs and return libname where label is exported
    def __find_in_libs(self, label):
        for lib in self.libs.files:
            found = False
            
            for exported_label in lib.symbols.exports:
                if exported_label.name == label:
                    found = True
                    break
            
            if found == True:
                return True, lib
            
        return False, None
        
    def __solve_imports(self):

        for file_item in self.files:
            for label_item in file_item.symbols.imports:

                name = label_item.name
                found, value = self.__find_exported_label(name)

                if found == False:
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


    def __include_libs(self):
        
        
        self.__get_exports()
        self.__find_imports()
        
        if len(self.missing_exports) == 0:
            return
            
        for label in self.missing_exports:
            found, lib = self.__find_in_libs(label)
            if found == False:
                print "Didn't found included label in object files", label
                sys.exit()
            else:
                self.files.append(lib)
        
        self.missing_exports = []
        
        self.__include_libs()
    
    
    def link(self):
        self.__include_libs()
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

class libraries():
    
    def __init__(self, libpaths):
        
        #parse all given paths and search for static libraries
        libpaths_walk = []    
        libobjs = []
        
        for path in libpaths:
            
            if os.path.isdir(path) == False:
                print "Directory " + path + " specified as lib dir but doesn't exist!"
                sys.exit()
            
            libpaths_walk = libpaths_walk + [x[0] for x in os.walk(os.path.abspath(path))]
                
        for path in libpaths_walk:
            path = os.path.abspath(path)
        
            if path[-1] == '/':
                libobjs = libobjs + glob.glob(path + "*.o")
            else:
                libobjs = libobjs + glob.glob(path + "/*.o")
        
        # append found static libraries into lib buffer
        self.files = []
        for name in libobjs:
            new_object_file = object_file(name)
            new_object_file.fill()
            self.files.append(new_object_file)

def usage():
    print """
Example usage: linker example1.o example2.o

        This is linker for MARK II Assembler. This program take list of object
    files as arguments and link them together into one load module.

Arguments:
    -h --help           Print this help.
    -o <file>           Output LDM file name. If not specified, name of first
                        object file will be used.
    -l <path>           Path to look for libraries.
       --version        Print version number and exit.
"""

def get_args():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:l:", ["help", "version"])
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)

    output_file = None
    libpaths = []
    
    for option, value in opts:
        if option in ("-h", "--help"):
            usage()
            sys.exit()
        elif option == "-o":
            output_file = value
        elif option == "--version":
            print "Linker for MARK-II CPU " + version.version
            sys.exit(1)
        elif option == "-l":
            libpaths.append(value)
        else:
            print "Unrecognized option " + option
            print "Type 'linker -h' for more informations."
            sys.exit(1)

    input_filenames = []

    for arg in args:
        input_filenames.append(arg)

    if len(input_filenames) == 0:
        print "Please specify input object files."
        sys.exit(1)

    if output_file == None:
        output_file = (input_filenames[0].split('.')[0]).split('/')[-1] + ".ldm"
    
    return output_file, input_filenames, libpaths


def main():

    output_file, input_files, libpaths = get_args()
    
    libs = libraries(libpaths)

    buff = object_buffer(input_files, libs)
    buff.link()
    buff.generate_output_file(output_file)

    return 0

if __name__ == '__main__':
    main()
    sys.exit()
