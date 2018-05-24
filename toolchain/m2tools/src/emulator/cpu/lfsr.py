#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  lfsr.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz

import random

class lfsr:
    def __init__(self, baseAddress, name):
        self.__name__ = name
        self.startAddress = baseAddress
        self.size = 0
        
    def read(self, address):
        if address == self.startAddress:        
            return random.randint(0, 4294967296)
        else:
            return None
        
