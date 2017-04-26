#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  emulator.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from cpu.MARK import MARK

import time;

class globalDefs():
    """Some usefull definitions are stored in this class"""

    F_CPU = 14400000
    rom0filename = "loop.eif"
    uart0_map = '/dev/pts/2'

def main(args):
    soc = MARK(globalDefs)

    while True:
        soc.tick()

    return 0

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))
