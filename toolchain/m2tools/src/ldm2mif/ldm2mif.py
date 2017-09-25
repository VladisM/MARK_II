#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  ldm2mif.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz

import version
import mif
import getopt, sys, math

class buffer_item(mif.buff_item):
    def __init__(self, address, value, relocation):
        mif.buff_item.__init__(self, address, value)

        if relocation == "True":
            self.relocation = True
        else:
            self.relocation = False

    def relocate(self, offset):

        if self.relocation == False:
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

    def __set_argument(instruction_argument):
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
            print "Doesn't not able recognize instruction!"
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
            print "Doesn't not able recognize instruction!"
            print "Instruction word: " + hex(self.value) + " stored at address: "+ hex(self.address)
            sys.exit(1)
        return instruction_argument


def createOutput(output_file, buff, size):

    miffile = mif.mif(mif.WRITE, output_file, size)

    if miffile.write(buff) != mif.OK:
        print "Can't create output mif file!"
        print miffile.errmsg
        sys.exit(1)

def usage():
    print """
Example usage: ldm2mif example.ldm

        This is simple utility to convert load module (.ldm) file from linker
    into memory inicialization file for Quartus II. Default address range of
    output file is 2^8.

Arguments:
    -h --help           Print this help.
    -o <file>           Output MIF name. If not specified name of input file
                        will be used.
    -r <address>        Relocate source. Addjust immediate addresses of these
                        instructions that use relative addresing using labels.
                        You have to specify <address> in hex where the code
                        will be stored. Default value is 0x000000.
    -s <size>           Size of memory, default value is 8. Memory range is
                        from 0 to 2^<size>.
       --version        Print version number and exit.
"""

def get_args():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:r:s:", ["help","version"])
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)

    input_file = None
    output_file = None
    start_address = 0
    size = 8

    for option, value in opts:
        if option in ("-h", "--help"):
            usage()
            sys.exit()
        elif option == "-o":
            output_file = value
        elif option == "-r":
            start_address = int(value, 16)
        elif option == "-s":
            size = int(value)
        elif option == "--version":
            print "ldm2mif for MARK-II CPU " + version.version
            sys.exit(1)
        else:
            print "Unrecognized option " + option
            print "Type 'ldm2mif -h' for more informations."
            sys.exit(1)

    if len(args) > 1:
        print "Too much argument given!"
        sys.exit(1)
    elif len(args) == 0:
        print "Name of input file is not specified!"
        sys.exit(1)

    input_file = args[0]

    if output_file == None:
        output_file = (input_file.split('.')[0]).split('/')[-1] + ".mif"

    return [input_file, output_file, start_address, size]

def main():

    input_file, output_file, start_address, size = get_args()

    try:
        f = file(input_file, "r")
    except:
        print "Can't open input file for reading!"
        sys.exit(1)

    buff = []

    for line in f:
        line = line.replace("\n", "")
        address, value, relocation = line.split(':')
        buff.append(buffer_item(int(address, 16), int(value,16), relocation))

    f.close()

    for item in buff:
        item.relocate(start_address)

    createOutput(output_file, buff, size)

    return 0

if __name__ == '__main__':
    main()
    sys.exit()
