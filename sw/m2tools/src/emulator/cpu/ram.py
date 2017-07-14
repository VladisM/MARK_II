#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  ram.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz


from memitem import memitem

class ram(memitem):
    def __init__(self, baseAddress, size, name):
        memitem.__init__(self, baseAddress, size,  name)
