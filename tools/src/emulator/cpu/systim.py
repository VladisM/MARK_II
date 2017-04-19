#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  systim.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from memitem import memitem
import sys, numpy, threading

class systim(memitem):
    def __init__(self, baseAddress, hInterrupt, globalDefs, name):
        memitem.__init__(self, baseAddress, 1, name)
        self.F_CPU = globalDefs.F_CPU
        self.hInterrupt = hInterrupt

        #create timer
        self.timObject = threading.Timer( (self.F_CPU**(-1)) / 1000.0, self.timTick )

    def start(self):
        self.timObject.start()

    def timTick(self):

        #is timer enabled?
        if (numpy.uint32(self.mem[0]) & 0x01000000) == 0x01000000:

            top = (numpy.uint32(self.mem[0]) & 0x00FFFFFF) / 1000

            # check compare match
            if top == self.mem[1]:
                self.mem[1] = 0
                #is int_en = 1?
                if (numpy.uint32(self.mem[0]) & 0x02000000) == 0x02000000:
                    #generate interrupt
                    self.hInterrupt(self.__name__)
            else:
                self.mem[1] = self.mem[1] + 1

        self.timObject = threading.Timer( (self.F_CPU**(-1)) / 1000.0, self.timTick )
        self.timObject.start()

    def write(self, address, value):
        if address >= self.startAddress and address <= self.endAddress and address - self.startAddress == 1:
            self.mem[1] = 0
        else:
            super(systim, self).write(address, value)

