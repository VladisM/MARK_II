#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  emul.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

class memitem():

    def __init__(self, baseAddress, size):
        self.startAddress = baseAddress
        self.endAddress = baseAddress + (2**size) - 1
        self.size = size
        self.mem = [0] * (2**size)

    def read(self, address):
        if address >= self.startAddress and address <= self.endAddress:
            return self.mem[address - self.startAddress]
        else:
            return None

    def write(self, address, value):
        if address >= self.startAddress and address <= self.endAddress:
            self.mem[address - self.startAddress] = value

    def reset():
        self.mem = [0] * (2**size)

