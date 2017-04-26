#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  MARK.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from cpu import cpu
from rom import rom
from ram import ram
from gpio import gpio
from systim import systim
from intControler import intControler
from uart import uart
import threading

class MARK():

    def __init__(self, globDef):
        self.mycpu = cpu(self.readFunction, self.writeFunction, self.retiFunction)
        self.myrom0 = rom(0x000000, 8, globDef, "rom0")
        self.mygpio0 = gpio(0x000100, "gpio0")
        self.myram0 = ram(0x000400, 10, "ram0")
        self.myram1 = ram(0x100000, 13, "ram1")
        self.mysystim0 = systim(0x000104, self.interrupt, globDef, "systim0")
        self.myintControler0 = intControler(0x000108, self.mycpu, "intControler0")
        self.uart0 = uart(0x00010A, self.interrupt, globDef.uart0_map, "uart0")
        self.F_CPU = globDef.F_CPU
        self.timObject = threading.Timer(self.F_CPU**(-1), self.tick)

    def readFunction(self, address):
        """CPU (master on bus) call this function to read data from specified address"""

        value = self.myrom0.read(address)
        if value != None:
            return value

        value = self.mygpio0.read(address)
        if value != None:
            return value

        value = self.myram0.read(address)
        if value != None:
            return value

        value = self.myram1.read(address)
        if value != None:
            return value

        value = self.mysystim0.read(address)
        if value != None:
            return value

        value = self.myintControler0.read(address)
        if value != None:
            return value

        value = self.uart0.read(address)
        if value != None:
            return value

        print "Address <" + hex(address) + "> is undefined. Aborting emulation!"
        sys.exit(1)

    def writeFunction(self, address, value):
        """Master on bus (CPU) call this function to write data into specified address"""

        self.myrom0.write(address, value)
        self.mygpio0.write(address, value)
        self.myram0.write(address, value)
        self.myram1.write(address, value)
        self.mysystim0.write(address, value)
        self.myintControler0.write(address, value)
        self.uart0.write(address, value)

    def hardReset(self):
        """Reset whole SoC, even peripherals that doesn't have reset input (like ROM, RAM...)"""
        self.myrom0.reset()
        self.mygpio0.reset()
        self.myram0.reset()
        self.myram1.reset()
        self.mycpu.reset()
        self.mysystim0.reset()
        self.myintControler0.reset()
        self.uart0.reset()

    def softReset(self):
        """Reset SoC, same as reset input on real hardware"""
        self.mycpu.reset()
        self.mygpio0.reset()
        self.mysystim0.reset()
        self.myintControler0.reset()
        self.uart0.reset()

    def retiFunction(self):
        self.myintControler0.completed()

    def interrupt(self, sourceName):
        self.myintControler0.interrupt(sourceName)

    def start(self):
        self.timObject.start()
        self.mysystim0.start()

    def tick(self):
        self.mycpu.tick()
        self.uart0.tick()
        self.timObject = threading.Timer(self.F_CPU**(-1), self.tick)
        self.timObject.start()

    def halt(self):
        self.timObject.cancel()
        self.mysystim0.timObject.cancel()
