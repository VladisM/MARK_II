#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  intControler.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from memitem import memitem

import numpy, sys

class intControler(memitem):
    def __init__(self, baseAddress, cpuObject, name):
        memitem.__init__(self, baseAddress, 0, name)
        self.cpu = cpuObject
        self.intActive = False
        self.stack = []

    def interrupt(self, sourceName):

        if self.intActive == False:

            if sourceName == "systim0":
                if numpy.uint32(self.mem[0]) & 0x00000001 == 0x00000001:
                    self.cpu.intVector = 1
                    self.intActive = True

            elif sourceName == "uart0_tx":
                if numpy.uint32(self.mem[0]) & 0x00000100 == 0x00000100:
                    self.cpu.intVector = 9
                    self.intActive = True

            elif sourceName == "uart0_rx":
                if numpy.uint32(self.mem[0]) & 0x00000200 == 0x00000200:
                    self.cpu.intVector = 10
                    self.intActive = True

            else:
                print "Recieved interrupt from unknown source: <", sourceName, ">"

        else:
            self.stack.append(sourceName)

    def completed(self):
        self.intActive = False
        if len(self.stack) > 0:
            self.interrupt(self.stack.pop())
