#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  rom.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz

from memitem import memitem
import sys
import mif

class rom(memitem):
    def __init__(self, baseAddress, size, rom0mif, name):
        memitem.__init__(self, baseAddress, size, name)
        self.loadmif(rom0mif)

    def loadmif(self, fileName):
        miffile = mif.mif(mif.READ, fileName)

        if miffile.read() == mif.OK:
            for item in miffile.outBuff:
                self.mem[item.address] = item.value
        else:
            print "Error in " + self.__name__ + "! Can't can't read input file <" + fileName + ">!"
            print miffile.errmsg
            sys.exit(1)
