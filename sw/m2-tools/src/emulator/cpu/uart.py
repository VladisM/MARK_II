#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  uart.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz


from memitem import memitem
import sys, numpy, serial

class uart(memitem):
    def __init__(self, baseAddress, hInterrupt, port, name):
        memitem.__init__(self, baseAddress, 1, name)
        self.hInterrupt = hInterrupt
        self.ser = serial.Serial(port, 9600, rtscts=True, dsrdtr=True)
        self.mapped_port = port
        self.oldInWaiting = 0

    def __del__(self):
        self.ser.close()

    def write(self, address, value):
        if address >= self.startAddress and address <= self.endAddress and address - self.startAddress == 0:
            self.ser.write(chr(value & 0xFF))
            self.hInterrupt(self.__name__ + "_tx")
        else:
            super(uart, self).write(address, value)

    def tick(self):
        if self.oldInWaiting != self.ser.inWaiting() and self.ser.inWaiting() > 0:
            self.oldInWaiting = self.ser.inWaiting()
            self.hInterrupt(self.__name__ + "_rx")

    def read(self, address):
        if address >= self.startAddress and address <= self.endAddress and address - self.startAddress == 0:
            if self.ser.inWaiting() > 0:
                self.mem[0] = ord(self.ser.read(1))
                self.oldInWaiting = self.oldInWaiting - 1
                return self.mem[0]
            else:
                return self.mem[0]
        else:
            super(uart, self).read(address)

    def reset(self):
        del self.ser
        self.ser = serial.Serial(self.mapped_port, 9600, rtscts=True, dsrdtr=True)
        super(uart, self).reset()
