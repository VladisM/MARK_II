#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  emulator.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

from cpu.MARK import MARK
import sys, version, getopt

class globalDefs():
    """Some usefull definitions are stored in this class"""

    rom0eif = "rom.eif"
    uart0map = '/dev/pts/2'

def usage():
    print """
Example usage: emulatory.py -p /dev/pts/2 -r rom.eif

        Simple emulator of MARK-II SoC. Emulating systim, uart0, rom0, ram0, ram1,
    intController and cpu. For more information please see:
    https://github.com/VladisM/MARK_II-SoC/

Arguments:
    -h --help           Print this help and exit.
    -p --port           Device where uart0 will be conected. Can be
                        /dev/pts/2 for example.
    -r --rom            Filename of file that will be loaded into rom0. Have to
                        be .eif format.
       --version        Print version number and exit.
    """

def get_args():

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hr:p:", ["help","port","rom","version"])
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)

    for option, value in opts:
        if option in ("-h", "--help"):
            usage()
            sys.exit()
        elif option == "--version":
            print "Emulator of MARK-II " + version.version
            sys.exit()
        elif option in ("-r", "--rom"):
            globalDefs.rom0eif = value
        elif option in ("-p", "--port"):
            globalDefs.uart0map = value
        else:
            print "Unrecognized option " + option
            print "Type 'emulator.py -h' for more informations."
            sys.exit(1)

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
