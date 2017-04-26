#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  rom.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from memitem import memitem
import sys

class rom(memitem):
    def __init__(self, baseAddress, size, rom0eif, name):
        memitem.__init__(self, baseAddress, size, name)
        self.loadeif(rom0eif)

    def loadeif(self, fileName):
        try:
            f = file(fileName, "r")
        except:
            print "Error in " + self.__name__ + "! Can't open input file <" + fileName + "> for reading!"
            sys.exit(1)

        i = 0
        for line in f:
            line.replace("\n", "")
            line.replace("\r", "")
            line.replace(" ", "")
            self.mem[i] = int(line.upper(), 16)
            i = i + 1

        f.close()
