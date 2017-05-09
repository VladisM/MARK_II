import version, getopt, sys

class globalDefs():
    """Some usefull definitions are stored in this class"""

    rom0eif = None
    uart0map = None

def usage():
    print """
Example usage: emulator -p /dev/pts/2 -r rom.eif

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

    if globalDefs.rom0eif == None:
        print "Missing file for rom0. Aborting emulation."
        sys.exit(1)

    if globalDefs.uart0map == None:
        print "Missing port for uart0. Aborting emulation."
        sys.exit(1)
