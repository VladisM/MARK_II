#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  gpio.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from memitem import memitem

class gpio(memitem):
    def __init__(self, baseAddress, name):
        memitem.__init__(self, baseAddress, 2, name)

    def getRegByName(self, regName):
        if regName == "PORTA":
            return self.mem[0]
        elif regName == "DDRA":
            return self.mem[1]
        elif regName == "PORTB":
            return self.mem[2]
        elif regName == "DDRB":
            return self.mem[3]
        else:
            return None
