#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  emulator.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from cpu.MARK import MARK
import sys

from args import *

def main(args):

    get_args()

    print "MARK-II emulator is running.\nUART0 mapped into \"" + globalDefs.uart0map + "\".\nTo stop execution use CTRL+C."

    soc = MARK(globalDefs.rom0eif, globalDefs.uart0map)

    while True:
        try:
            soc.tick()
        except KeyboardInterrupt:
            soc.reset()
            del soc
            print "\nEmulator halted by CTRL+C, exiting now.."
            break
        except SystemExit:
            soc.reset()
            del soc
            print "Emulator halted by internall call sys.exit(), exiting now..."
            break

    return 0

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))
