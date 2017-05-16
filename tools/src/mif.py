import math

WRITE = 1
READ = 2

ERR_BAD_MODE = -1
ERR_INS_OUT_OF_RANGE = -2
ERR_CANT_WRITE_FILE = -3
ERR_MISSING_SIZE = -4
ERR_CANT_READ_FILE = -5
ERR_FILE_UNSPECIFIED_LABEL = -6
ERR_MIF_ZERO_DEPTH = -7
ERR_MIF_BAD_WIDTH = -8
ERR_MIF_INV_ADD_RAD = -9
ERR_MIF_INV_DAT_RAD = -10
ERR_DATA_IS_LARGER = -11

OK = 0

class buff_item:
    def __init__(self, address, value):
        self.address = address
        self.value = value

class mif:
    def __init__(self, mode, filename, size=None):
        self.errmsg = None

        self.mode = mode
        self.filename = filename
        self.size = size
        self.outBuff = []

    def write(self, buff):

        #check mode
        if self.mode != WRITE:
            self.errmsg = "Write method called for file in read mode."
            return ERR_BAD_MODE

        if self.size == None:
            self.errmsg = "Mif is in write mode but without specified size."
            return ERR_MISSING_SIZE

        #create temp buffer for placing data in
        outbuff = [0] * (2**self.size)

        #prepare count of leading zeros
        zerocount = int(math.ceil(self.size/4.0))

        for item in buff:

            if item.address > ((2**self.size) - 1):
                self.errmsg = "Instruction at " + hex(self.address) + " instruction word: " + hex(self.value) + " is out of memory range!"
                return ERR_INS_OUT_OF_RANGE

            outbuff[item.address] = item.value

        #try to open file for writing
        try:
            of = file(self.filename, "w")
        except:
            self.errmsg = "Can't open output file for writing!"
            return ERR_CANT_WRITE_FILE

        #print data into memory
        of.write("DEPTH = " + str(2**self.size))
        of.write(";\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\n\nCONTENT BEGIN\n")

        for n in range(0, 2**self.size):

            address = hex(n).split('x')[1].zfill(zerocount)
            value = hex(outbuff[n])
            value = value.split('x')[1]
            value = value.zfill(8)

            of.write(address)
            of.write(" : ")
            of.write(value)
            of.write(";\n")

        of.write("END\n")

        of.close()

    def read(self):
        if self.mode != READ:
            self.errmsg = "Read method called for file in write mode."
            return ERR_BAD_MODE

        try:
            inputFile = file(self.filename, 'r')
        except:
            self.errmsg = "Can't read input file."
            return ERR_CANT_READ_FILE


        content = False

        dat_rad = None
        add_rad = None
        width = 0
        depth = 0

        for line in inputFile:

            #remove  all mess from line
            for char in ("\t", ",", "\n", "\r", ";", " "):
                line = line.replace(char, "")

            if content == False:

                if line != "CONTENTBEGIN":

                    #split line
                    line = line.split("=")

                    if line[0] == "DEPTH":
                        depth = int(line[1])
                    elif line[0] == "WIDTH":
                        width = int(line[1])
                    elif line[0] == "ADDRESS_RADIX":
                        add_rad = line[1]
                    elif line[0] == "DATA_RADIX":
                        dat_rad = line[1]
                    else:
                        if line != [""]:
                            self.errmsg = "While reading input file, unknow label was found: " + str(line)
                            return ERR_FILE_UNSPECIFIED_LABEL

                else:
                    content = True

                    if dat_rad != "HEX":
                        self.errmsg = "Invalid radix of data column in mif."
                        return ERR_MIF_INV_DAT_RAD
                    if add_rad != "HEX":
                        self.errmsg = "Invalid radix of address column in mif."
                        return ERR_MIF_INV_ADD_RAD
                    if width != 32:
                        self.errmsg = "Invalid width of data in mif."
                        return ERR_MIF_BAD_WIDTH
                    if depth == 0:
                        self.errmsg = "Depth of mif is 0."
                        return ERR_MIF_ZERO_DEPTH

            else:
                if line != "END":
                    line = line.split(":")

                    new_item = buff_item(int(line[0], 16), int(line[1], 16))
                    self.outBuff.append(new_item)

                    if len(self.outBuff) > depth:
                        self.errmsg = "Data in mif is larger than specified depth."
                        return ERR_DATA_IS_LARGER

        inputFile.close()
        return OK
