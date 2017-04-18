#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  gpio.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from memitem import memitem

class gpio(memitem):
    def __init__(self, baseAddress):
        memitem.__init__(self, baseAddress, 2)