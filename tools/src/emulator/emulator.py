#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  emulator.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from cpu import cpu
from rom import rom
from ram import ram
from gpio import gpio

import time

def readFunction(address):
    value = myrom.read(address)
    if value != None:
        return value

    value = mygpio.read(address)
    if value != None:
        return value

    value = myram0.read(address)
    if value != None:
        return value

    value = myram1.read(address)
    if value != None:
        return value

    print "Address <" + hex(address) + "> is undefined. Aborting emulation!"
    sys.exit(1)

def writeFunction(address, value):
    myrom.write(address, value)
    mygpio.write(address, value)
    myram0.write(address, value)
    myram1.write(address, value)

def reset():
    myrom.reset()
    mygpio.reset()
    myram0.reset()
    myram1.reset()
    mycpu.reset()

mycpu = cpu(readFunction, writeFunction)
myrom = rom(0x000000, 8)
mygpio = gpio(0x000100)
myram0 = ram(0x000400, 10)
myram1 = ram(0x100000, 13)

def main(args):
    myrom.loadeif("rom.eif")
    while True:
        mycpu.tick()
        print mygpio.mem[0]
        time.sleep(0.3)

    return 0

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))
