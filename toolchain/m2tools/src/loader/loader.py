#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  loader.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz

import version, getopt, sys, serial, time

class buffer_item():
    def __init__(self, address, value, relocation):
        self.address = address
        self.value = value

        if relocation == "True":
            self.relocation = True
        else:
            self.relocation = False

    def relocate(self, offset):

        self.address = self.address + offset

        if self.relocation == False:
            return;

        instruction_type = (self.value & 0xF0000000) >> 28
        instruction_argument = self.__get_argument()

        if instruction_type >= 8:
            instruction_argument = instruction_argument + offset
        else:
            print "I have to relocate instruction that don't have address in it opcode. Probably broken assembler!"
            print "Instruction word: " + hex(self.value) + " stored at address: "+ hex(self.address)
            sys.exit(1)

        if instruction_argument > 0x00FFFFFF:
            print "Address in opcode overflow after relocation! Put your code into another place!"
            print "Instruction word: " + hex(self.value) + " stored at address: "+ hex(self.address)
            sys.exit(1)

        self.__set_argument(instruction_argument)

    def __set_argument(self, instruction_argument):
        instruction_type = (self.value & 0xF0000000) >> 28
        if instruction_type == 8:
            instruction_argument = instruction_argument << 4
            self.value = instruction_argument | (self.value & 0xF000000F)

        elif instruction_type == 9:
            instruction_argument = instruction_argument << 4
            self.value = instruction_argument | (self.value & 0xF000000F)

        elif instruction_type == 10:
            instruction_argument = ((instruction_argument & 0x00FFFFF0) << 4) | (instruction_argument & 0x0000000F)
            self.value = instruction_argument | (self.value & 0xF00000F0)

        elif instruction_type == 11:
            instruction_argument = ((instruction_argument & 0x00F00000) << 4) | (instruction_argument & 0x000FFFFF)
            self.value = instruction_argument | (self.value & 0xF0F00000)

        elif instruction_type == 12:
            instruction_argument = ((instruction_argument & 0x00F00000) << 4) | (instruction_argument & 0x000FFFFF)
            self.value = instruction_argument | (self.value & 0xF0F00000)

        elif instruction_type == 13:
            instruction_argument = instruction_argument << 4
            self.value = instruction_argument | (self.value & 0xF000000F)

        else:
            print "Doesn't not able recognize instruction!"
            print "Instruction word: " + hex(self.value) + " stored at address: "+ hex(self.address)
            sys.exit(1)

    def __get_argument(self):
        instruction_type = (self.value & 0xF0000000) >> 28
        if instruction_type == 8:
            instruction_argument = (self.value & 0x0FFFFFF0) >> 4
        elif instruction_type == 9:
            instruction_argument = (self.value & 0x0FFFFFF0) >> 4
        elif instruction_type == 10:
            instruction_argument = ((self.value & 0x0FFFFF00) >> 4) | (self.value & 0x0000000F)
        elif instruction_type == 11:
            instruction_argument = ((self.value & 0x0F000000) >> 4) | (self.value & 0x000FFFFF)
        elif instruction_type == 12:
            instruction_argument = ((self.value & 0x0F000000) >> 4) | (self.value & 0x000FFFFF)
        elif instruction_type == 13:
            instruction_argument = (self.value & 0x0FFFFFF0) >> 4
        else:
            print "Doesn't not able recognize instruction!"
            print "Instruction word: " + hex(self.value) + " stored at address: "+ hex(self.address)
            sys.exit(1)
        return instruction_argument


def usage():
    print """
Example usage: loader -b 0x400 -p /dev/ttyUSB0 example.ldm

        Simple utility to load program into MARK-II using default serial
    bootloader. For more information please see following link:
    https://www.github.com/VladisM/MARK_II

Arguments:
    -h --help           Print this help.
    -b <address>        Base address, using hex C like syntax, to store source.
                        Loader also perform relocation of the given source to
                        this address.
    -p <port>           Port where MARK-II is connected. For example
                        /dev/ttyUSB0.
       --baudrate       Set baudrate for port. Default value is 38400.
       --version        Print version number and exit.
       --fileout		Generate C file for fast loading.
    -e --emulator       Add this option if you are connecting to emulator.
"""

def get_args():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hb:p:e", ["fileout","help","version","baudrate=","emulator"])
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)

    input_file = None
    base_address = None
    port = None
    baudrate = 38400
    emulator = False
    fileout = False
    
    for option, value in opts:
        if option in ("-h", "--help"):
            usage()
            sys.exit()
        elif option == "-b":
            base_address = int(value, 16)
        elif option == "-p":
            port = value
        elif option == "--version":
            print "loader for MARK-II CPU " + version.version
            sys.exit(1)
        elif option == "--baudrate":
            baudrate = int(value)
        elif option in ("-e", "--emulator"):
            emulator = True
        elif option == "--fileout":
            fileout = True
        else:
            print "Unrecognized option " + option
            print "Type 'loader -h' for more informations."
            sys.exit(1)

    if len(args) > 1:
        print "Too much argument given!"
        sys.exit(1)
    elif len(args) == 0:
        print "Name of input file is not specified!"
        sys.exit(1)

    if port == None:
        print "You have to specify port where MARK-II is connected!"
        sys.exit(1)

    if base_address == None:
        print "You have to specify start address where to store your programm."
        sys.exit(1)

    input_file = args[0]


    return [input_file, base_address, port, baudrate, emulator, fileout]

def send_char(char_to_send, port):
    port.write(char_to_send)

    waiting = True
    while waiting == True:
        if port.in_waiting > 0 and int((port.read(1)).encode('hex'), 16) == 0xBB:
            waiting = False

def main():

    input_file, base_address, port, baudrate, emulator, fileout = get_args()

    try:
        f = file(input_file, "r")
    except:
        print "Can't open input file for reading!"
        sys.exit(1)

    buff = []

    for line in f:
        line = line.replace("\n", "")
        address, value, relocation = line.split(':')
        buff.append(buffer_item(int(address, 16), int(value,16), relocation))

    f.close()

    #relocate all instructions and also get size
    max_address = 0
    for item in buff:
        item.relocate(base_address)

        if item.address > max_address:
            max_address = item.address

    size = max_address - base_address + 1

    tmpbuff = [0]*size

    for item in buff:
        tmpbuff[item.address - base_address] = item.value

    buff = tmpbuff
    
    if fileout == False:
        
        #send everithing

        if emulator == True:
            ser = serial.Serial(port, baudrate, rtscts=True, dsrdtr=True)
        else:
            ser = serial.Serial(port, baudrate)

        #try connect to loader in MARK
        
        print "Trying to connect..."
        
        ser.write(chr(0x55))
        time.sleep(2)

        if ser.in_waiting > 0:
            response = int((ser.read(1)).encode('hex'), 16)
            if response != 0xAA:
                print "Can't connect to MARK II Loader. Aborting..."
                return 1
            else:
                print "Connected, sending " + str(size * 4) + " bytes of data. Please wait..."
        else:
            print "Can't connect to MARK II Loader. Aborting..."
            return 1

        #send data
        
        send_char(chr((base_address >> 16) & 0xFF), ser)
        send_char(chr((base_address >> 8) & 0xFF), ser)
        send_char(chr(base_address & 0xFF), ser)

        send_char(chr((size >> 16) & 0xFF), ser)
        send_char(chr((size >> 8) & 0xFF), ser)
        send_char(chr(size & 0xFF), ser)

        counter = 1
        for value in buff:
            send_char(chr((value >> 24) & 0xFF), ser)
            send_char(chr((value >> 16) & 0xFF), ser)
            send_char(chr((value >> 8) & 0xFF), ser)
            send_char(chr(value & 0xFF), ser)
            
            sys.stdout.write("\rSent: " + str(counter * 4) + "/" + str(size * 4) + " ")
            sys.stdout.flush()
            counter = counter + 1
            
        sys.stdout.write("\nDone...\n")
        sys.stdout.flush()
        ser.close()
    
    else:
		create_file(port, baudrate, base_address, size, buff)
    
    return 0

def create_file(port, baudrate, base_address, size, buff):
	f = open("fast_load.c", "w")
        
	f.write("""/*
 * Based on example from:
 * https://p5r.uk/blog/2009/linux-serial-programming-example.html
 */

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termios.h>
#include <errno.h>

""")

	f.write('#define PORT "' + port + '"\n')
	f.write('#define BAUDRATE B' + str(baudrate) + '\n\n')
	    
	f.write("char data[] = {\n")        
	
	f.write(hex((base_address >> 16) & 0xFF) + ", ")
	f.write(hex((base_address >> 8) & 0xFF) + ", ")
	f.write(hex((base_address >> 0) & 0xFF) + ", ")
	
	f.write("\n")
	
	size = size + 1
	
	f.write(hex((size >> 16) & 0xFF) + ", ")
	f.write(hex((size >> 8) & 0xFF) + ", ")
	f.write(hex((size >> 0) & 0xFF) + ", ")
			
	f.write("\n")
	
	counter = 6
	
	for value in buff:
		f.write(hex((value >> 24) & 0xFF) + ", ")
		f.write(hex((value >> 16) & 0xFF) + ", ")
		f.write(hex((value >> 8) & 0xFF) + ", ")
		f.write(hex((value >> 0) & 0xFF) + ", ")
		counter = counter + 4
		f.write("\n")
		
	f.write("0x00 };\n");
	f.write("int count = " + str(counter) + ";\n")
	
	f.write(""" 

int main(void)
{
    int fd;
    struct termios old_termios;
    struct termios new_termios;
    
    fd = open(PORT, O_RDWR | O_NOCTTY);
    if (fd < 0) {
        fprintf(stderr, "error, counldn't open file %s\\n", PORT);
        return 1;
    }
    if (tcgetattr(fd, &old_termios) != 0) {
        fprintf(stderr, "tcgetattr(fd, &old_termios) failed: %s\\n", strerror(errno));
        return 1;
    }
    memset(&new_termios, 0, sizeof(new_termios));
    new_termios.c_iflag = IGNPAR;
    new_termios.c_oflag = 0;
    new_termios.c_cflag = CS8 | CREAD | CLOCAL | HUPCL;
    new_termios.c_lflag = 0;
    new_termios.c_cc[VINTR]    = 0;
    new_termios.c_cc[VQUIT]    = 0;
    new_termios.c_cc[VERASE]   = 0;
    new_termios.c_cc[VKILL]    = 0;
    new_termios.c_cc[VEOF]     = 4;
    new_termios.c_cc[VTIME]    = 0;
    new_termios.c_cc[VMIN]     = 1;
    new_termios.c_cc[VSWTC]    = 0;
    new_termios.c_cc[VSTART]   = 0;
    new_termios.c_cc[VSTOP]    = 0;
    new_termios.c_cc[VSUSP]    = 0;
    new_termios.c_cc[VEOL]     = 0;
    new_termios.c_cc[VREPRINT] = 0;
    new_termios.c_cc[VDISCARD] = 0;
    new_termios.c_cc[VWERASE]  = 0;
    new_termios.c_cc[VLNEXT]   = 0;
    new_termios.c_cc[VEOL2]    = 0;

    if (cfsetispeed(&new_termios, BAUDRATE) != 0) {
        fprintf(stderr, "cfsetispeed(&new_termios, BAUDRATE) failed: %s\\n", strerror(errno));
        return 1;
    }
    if (cfsetospeed(&new_termios, BAUDRATE) != 0) {
        fprintf(stderr, "cfsetospeed(&new_termios, BAUDRATE) failed: %s\\n", strerror(errno));
        return 1;
    }
    if (tcsetattr(fd, TCSANOW, &new_termios) != 0) {
        fprintf(stderr, "tcsetattr(fd, TCSANOW, &new_termios) failed: %s\\n", strerror(errno));
        return 1;
    }


    // Now read() and write() to the device at your heart's delight
    
    char greet[] = {0x55};  
    write(fd, &greet, 1);
    
    int per = count / 100;
    int total = 0;
    int total_counter = 0;
    
    printf("Sent: 0%%");
    fflush(stdout);
    
    for(int i = 0; i < count; i++){
        int x,y = 0;
        write(fd, &(data[i]), 1);
        do{
            y = read(fd,&x,1);
        }
        while(y != 1);
        
        total_counter++;
        if(total_counter == per){
            total++;
            total_counter = 0;
			printf("\\rSent: %d%%", total);
            fflush(stdout);
        }        
    }
    printf("\\nDone\\n");
    
    // Before leaving, reset the old serial settings.
    tcsetattr(fd, TCSANOW, &old_termios);
    return 0;
}
""")
        
	f.close()


if __name__ == '__main__':
    sys.exit(main())
