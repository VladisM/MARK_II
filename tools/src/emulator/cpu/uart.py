#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  uart.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from memitem import memitem
import sys, numpy, serial

class uart(memitem):
    def __init__(self, baseAddress, hInterrupt, port, name):
        memitem.__init__(self, baseAddress, 1, name)
        self.hInterrupt = hInterrupt
        self.ser = serial.Serial(port, 9600, rtscts=True, dsrdtr=True)

    def write(self, address, value):
        if address >= self.startAddress and address <= self.endAddress and address - self.startAddress == 0:
            print "have to send ", value
            self.ser.write(chr(value))
        else:
            super(uart, self).write(address, value)
