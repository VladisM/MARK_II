#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  intControler.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz


from memitem import memitem

import numpy, sys

class intControler(memitem):
    def __init__(self, baseAddress, cpuObject, name):
        self.cpu = cpuObject
        self.intActive = False
        self.stack = []

        self.__name__ = name

        self.startAddress = baseAddress
        self.endAddress = baseAddress + (2**4)
        self.size = 2**4 + 1
        self.mem = [0] * ((2**4) + 1)


    def read(self, address):
        if address >= self.startAddress and address <= self.endAddress:
            return self.mem[address - self.startAddress]
        else:
            return None

    def write(self, address, value):
        if address >= self.startAddress and address <= self.endAddress:
            self.mem[address - self.startAddress] = value

    def reset(self):
        self.mem = [0] * ((2**4) + 1)


    def interrupt(self, sourceName):

        if self.intActive == False:

            if sourceName == "cpu0":
                if numpy.uint32(self.mem[0]) & 0x0001 == 0x0001:
                    self.cpu.intVector = self.mem[1]
                    self.cpu.intrq = True
                    self.intActive = True

            elif sourceName == "systim0":
                if numpy.uint32(self.mem[0]) & 0x0002 == 0x0002:
                    self.cpu.intVector = self.mem[2]
                    self.cpu.intrq = True
                    self.intActive = True

            elif sourceName == "uart0":
                if numpy.uint32(self.mem[0]) & 0x0100 == 0x0100:
                    self.cpu.intVector = self.mem[9]
                    self.cpu.intrq = True
                    self.intActive = True

            else:
                print "Recieved interrupt from unknown source: <", sourceName, ">"

        else:
            self.stack.append(sourceName)

    def completed(self):
        self.intActive = False
        if len(self.stack) > 0:
            self.interrupt(self.stack.pop())

    def reset(self):
        self.intActive = False
        self.stack = []
        super(intControler, self).reset()
