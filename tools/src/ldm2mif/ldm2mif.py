#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  ldm2mif.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

import version

import getopt, sys, math

class buffer_item():
    def __init__(self, address, value, relocation):
        self.address = int(address, 16)
        self.value = int(value, 16)
        if relocation == "True":
            self.relocation = True
        else:
            self.relocation = False

    def relocate(self, offset):

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

    def echo(self):
        print "Instruction at " + hex(self.address) + " instruction word: " + hex(self.value)

def createOutput(output_file, buff, size):

    outbuff = [0] * (2**size)

    zerocount = int(math.ceil(size/4.0))

    for item in buff:
        if item.address > ((2**size) - 1):
            print "Instruction at " + hex(self.address) + " instruction word: " + hex(self.value) + " is out of memory range!"
            sys.exit(1)

        outbuff[item.address] = item.value

    try:
        of = file(output_file, "w")
    except:
        print "Can't open output file for writing!"
        sys.exit(1)

    of.write("DEPTH = " + str(2**size))
    of.write(";\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\n\nCONTENT BEGIN\n")

    for n in range(0, 2**size):

        address = hex(n).split('x')[1].zfill(zerocount)
        value = hex(outbuff[n])
        value = value.split('x')[1]
        value = value.zfill(8)

        of.write(address)
        of.write(" : ")
        of.write(value)
        of.write(";\n")

    of.write("END\n")

    of.close()

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
    -d                  Run in debug mode.
    -s <size>           Size of memory, default value is 8. Memory range is
                        from 0 to 2^<size>.
       --version        Print version number and exit.
"""

def get_args():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:r:ds:", ["help","version"])
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)

    input_file = None
    output_file = None
    start_address = 0
    debug = False
    size = 8

    for option, value in opts:
        if option in ("-h", "--help"):
            usage()
            sys.exit()
        elif option == "-o":
            output_file = value
        elif option == "-r":
            start_address = int(value, 16)
        elif option == "-d":
            debug = True
        elif option == "-s":
            size = int(value)
        elif option == "--version":
            print "ldm2mif for MARK-II CPU " + version.version
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
        output_file = (input_file.split('.')[0]).split('/')[-1] + ".mif"

    return [input_file, output_file, start_address, debug, size]

def main():

    input_file, output_file, start_address, debug, size = get_args()

    if debug == True:
        print "Conversion into mif started with following argumenst:"
        print "\tInput file: " + input_file
        print "\tOutput file: " + output_file
        print "\tStart address: " + hex(start_address)
        print "\tDebug: " + str(debug)
        print "Loading file for parsing."

    try:
        f = file(input_file, "r")
    except:
        print "Can't open input file for reading!"
        sys.exit(1)

    buff = []

    for line in f:
        line = line.replace("\n", "")
        address, value, relocation = line.split(':')
        buff.append(buffer_item(address, value, relocation))

    f.close()

    if debug == True:
        print "Input file parsing is done.\nPrinting out buffer."
        for item in buff: item.echo()
        print "Starting relocation."

    for item in buff:
        item.relocate(start_address)

    if debug == True:
        print "Printing out buffer after relocation."
        for item in buff: item.echo()
        print "Generating output file."

    createOutput(output_file, buff, size)

    return 0

if __name__ == '__main__':
    main()
    sys.exit()
