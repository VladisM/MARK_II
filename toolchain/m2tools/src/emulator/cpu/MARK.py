#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  MARK.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz


from cpu import cpu
from rom import rom
from ram import ram
from systim import systim
from intControler import intControler
from uart import uart

import sys

class MARK():

    def __init__(self, rom0mif, uart0_map):
        self.cpu0 = cpu(self.readFunction, self.writeFunction, self.retiFunction, self.interrupt, "cpu0")
        self.rom0 = rom(0x000000, 8, rom0mif, "rom0")
        self.ram0 = ram(0x000400, 10, "ram0")
        self.ram1 = ram(0x100000, 13, "ram1")
        self.systim0 = systim(0x000104, self.interrupt, "systim0")
        self.intControler0 = intControler(0x00010F, self.cpu0, "intControler0")
        self.uart0 = uart(0x000130, self.interrupt, uart0_map, "uart0")

    def readFunction(self, address):
        """CPU (master on bus) call this function to read data from specified address"""

        value = self.rom0.read(address)
        if value != None: return value

        value = self.ram0.read(address)
        if value != None: return value

        value = self.ram1.read(address)
        if value != None: return value

        value = self.systim0.read(address)
        if value != None: return value

        value = self.intControler0.read(address)
        if value != None: return value

        value = self.uart0.read(address)
        if value != None: return value

        print "Read mem error. Address <" + hex(address) + "> is undefined. Aborting emulation!"
        sys.exit(1)

    def writeFunction(self, address, value):
        """Master on bus (CPU) call this function to write data into specified address"""

        self.rom0.write(address, value)
        self.ram0.write(address, value)
        self.ram1.write(address, value)
        self.systim0.write(address, value)
        self.intControler0.write(address, value)
        self.uart0.write(address, value)

    def reset(self):
        """Reset SoC, same as reset input on real hardware"""
        self.cpu0.reset()
        self.systim0.reset()
        self.intControler0.reset()
        self.uart0.reset()

    def retiFunction(self):
        self.intControler0.completed()

    def interrupt(self, sourceName):
        self.intControler0.interrupt(sourceName)

    def tick(self):
        self.cpu0.tick()
        self.uart0.tick()
        self.systim0.tick()
