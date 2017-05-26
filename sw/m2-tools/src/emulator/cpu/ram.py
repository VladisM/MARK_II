#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  ram.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from memitem import memitem

class ram(memitem):
    def __init__(self, baseAddress, size, name):
        memitem.__init__(self, baseAddress, size,  name)
