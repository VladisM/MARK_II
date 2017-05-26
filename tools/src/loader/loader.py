#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  loader.py

import version, getopt, sys, serial

class buffer_item():
    def __init__(self, address, value, relocation):
        self.address = address
        self.value = value

        if relocation == "True":
            self.relocation = True
        else:
            self.relocation = False

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

def usage():
    print """
Example usage: loader -b 0x400 -p /dev/ttyUSB0 example.ldm

        Simple utility to load program into MARK-II using default serial
    bootloader. For more information please see following link:
    https://www.github.com/VladisM/MARK_II

Arguments:
    -h --help           Print this help.
    -b <address>        Base address, using hex C like syntax, to store source.
                        Loader also perform relocation of the given source to
                        this address.
    -p <port>           Port where MARK-II is connected. For example
                        /dev/ttyUSB0.
       --baudrate       Set baudrate for port. Default value is 1200.
       --version        Print version number and exit.
"""

def get_args():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hb:p:", ["help","version","baudrate="])
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)

    input_file = None
    base_address = None
    port = None
    baudrate = 1200

    for option, value in opts:
        if option in ("-h", "--help"):
            usage()
            sys.exit()
        elif option == "-b":
            base_address = int(value, 16)
        elif option == "-p":
            port = value
        elif option == "--version":
            print "ldm2mif for MARK-II CPU " + version.version
            sys.exit(1)
        elif option == "--baudrate":
            baudrate = int(value)
        else:
            print "Unrecognized option " + option
            print "Type 'loader -h' for more informations."
            sys.exit(1)

    if len(args) > 1:
        print "Too much argument given!"
        sys.exit(1)
    elif len(args) == 0:
        print "Name of input file is not specified!"
        sys.exit(1)

    if port == None:
        print "You have to specify port where MARK-II is connected!"
        sys.exit(1)

    if base_address == None:
        print "You have to specify start address where to store your programm."
        sys.exit(1)

    input_file = args[0]


    return [input_file, base_address, port, baudrate]

def main():

    input_file, base_address, port, baudrate = get_args()

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

    #relocate all instructions and also get size
    max_address = 0
    for item in buff:
        item.relocate(base_address)

        if item.address > max_address:
            max_address = item.address

    size = max_address - base_address + 1

    tmpbuff = [0]*size

    for item in buff:
        tmpbuff[item.address - base_address] = item.value

    buff = tmpbuff

    #send everithing
    ser = serial.Serial(port, baudrate, rtscts=True, dsrdtr=True)

    ser.write(chr((base_address >> 16) & 0xFF))
    ser.write(chr((base_address >> 8) & 0xFF))
    ser.write(chr(base_address & 0xFF))

    ser.write(chr((size >> 16) & 0xFF))
    ser.write(chr((size >> 8) & 0xFF))
    ser.write(chr(size & 0xFF))

    for value in buff:
        ser.write(chr((value >> 24) & 0xFF))
        ser.write(chr((value >> 16) & 0xFF))
        ser.write(chr((value >> 8) & 0xFF))
        ser.write(chr(value & 0xFF))

    ser.close()

    return 0

if __name__ == '__main__':
    sys.exit(main())
