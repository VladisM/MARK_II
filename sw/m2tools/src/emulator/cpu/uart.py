#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  uart.py
#
# Part of MARK II project. For informations about license, please
# see file /LICENSE .
#
# author: Vladislav Mlejnecký
# email: v.mlejnecky@seznam.cz


import sys, numpy, serial

class uart():
    def __init__(self, baseAddress, hInterrupt, port, name):
        self.__name__ = name

        self.startAddress = baseAddress
        self.endAddress = baseAddress + (2**2) - 1
        self.size = 2

        self.control_reg = 0
        self.status_reg = 0
        self.status_reg_read = False

        self.hInterrupt = hInterrupt

        self.ser = serial.Serial(port, 9600, rtscts=True, dsrdtr=True)
        self.mapped_port = port

        self.oldInWaiting = 0
        self.txfifo = fifo()
        self.rxfifo = fifo()

    def __del__(self):
        self.ser.close()

    def write(self, address, value):
        regsel = self.__reg_sel(address)
        if regsel == 1:
            self.txfifo.write(value & 0xFF)
        elif regsel == 4:
            self.control_reg = value

    def tick(self):

        tx_byte_sent = False
        rx_byte_come = False

        if self.ser.inWaiting() > 0:
            if self.control_reg & 0x20000 == 0x20000:
                self.rxfifo.write(ord(self.ser.read(1)))
                rx_byte_come = True

        if self.txfifo.count > 0:
            if self.control_reg & 0x10000 == 0x10000:
                value = self.txfifo.read()
                self.ser.write(chr(value & 0xFF))

        self.control_reg = (self.control_reg & 0xFFFFFFC0) | (self.rxfifo.count & 0x3F)
        self.control_reg = (self.control_reg & 0xFFFFF03F) | ((self.txfifo.count & 0x3F) << 6)

        if self.control_reg & 0x40000 == 0x40000:   #test for interrupts
            if self.rxfifo.check_full() and self.__is_int_enabled("rfint") and not(self.__is_flag_set("rfif")):
                self.__set_flag("rfif")
                self.hInterrupt(self.__name__)

            elif self.rxfifo.check_half() and self.__is_int_enabled("rhint") and not(self.__is_flag_set("rhif")):
                self.__set_flag("rhif")
                self.hInterrupt(self.__name__)

            elif rx_byte_come and self.__is_int_enabled("rxint") and not(self.__is_flag_set("rxif")):
                self.__set_flag("rxif")
                self.hInterrupt(self.__name__)

            elif self.txfifo.check_empty() and self.__is_int_enabled("teint") and not(self.__is_flag_set("teif")):
                self.__set_flag("teif")
                self.hInterrupt(self.__name__)

            elif self.txfifo.check_half() and self.__is_int_enabled("thint") and not(self.__is_flag_set("thif")):
                self.__set_flag("thif")
                self.hInterrupt(self.__name__)

            elif tx_byte_sent and self.__is_int_enabled("txint") and not(self.__is_flag_set("txif")):
                self.__set_flag("txif")
                self.hInterrupt(self.__name__)


    def __is_int_enabled(self, name):
        if   name == "rfint":
            if self.control_reg & 0x80000 == 0x80000:
                return True
            else:
                return False
        elif name == "rhint":
            if self.control_reg & 0x100000 == 0x100000:
                return True
            else:
                return False
        elif name == "rxint":
            if self.control_reg & 0x200000 == 0x200000:
                return True
            else:
                return False
        elif name == "teint":
            if self.control_reg & 0x400000 == 0x400000:
                return True
            else:
                return False
        elif name == "thint":
            if self.control_reg & 0x800000 == 0x800000:
                return True
            else:
                return False
        elif name == "txint":
            if self.control_reg & 0x1000000 == 0x1000000:
                return True
            else:
                return False

    def __is_flag_set(self, name):
        if   name == "rfif":
            if self.status_reg & 0x1000 == 0x1000:
                return True
            else:
                return False
        elif name == "rhif":
            if self.status_reg & 0x2000 == 0x2000:
                return True
            else:
                return False
        elif name == "rxif":
            if self.status_reg & 0x4000 == 0x4000:
                return True
            else:
                return False
        elif name == "teif":
            if self.status_reg & 0x8000 == 0x8000:
                return True
            else:
                return False
        elif name == "thif":
            if self.status_reg & 0x10000 == 0x10000:
                return True
            else:
                return False
        elif name == "txif":
            if self.status_reg & 0x20000 == 0x20000:
                return True
            else:
                return False

    def __set_flag(self, name):
        if   name == "rfif":
            self.status_reg = (self.status_reg & 0xFFFFEFFF) | 0x1000
        elif name == "rhif":
            self.status_reg = (self.status_reg & 0xFFFFDFFF) | 0x2000
        elif name == "rxif":
            self.status_reg = (self.status_reg & 0xFFFFBFFF) | 0x4000
        elif name == "teif":
            self.status_reg = (self.status_reg & 0xFFFF7FFF) | 0x8000
        elif name == "thif":
            self.status_reg = (self.status_reg & 0xFFFEFFFF) | 0x10000
        elif name == "txif":
            self.status_reg = (self.status_reg & 0xFFFDFFFF) | 0x20000

    def read(self, address):
        regsel = self.__reg_sel(address)
        if regsel == 2:
            return self.rxfifo.read()
        elif regsel == 3:
            self.status_reg_read = True
            return self.status_reg
        elif regsel == 4:
            return self.control_reg
        else:
            return None

    def reset(self):
        del self.ser
        self.ser = serial.Serial(self.mapped_port, 9600, rtscts=True, dsrdtr=True)
        self.status_reg = 0
        self.control_reg = 0
        self.txfifo.reset()
        self.rxfifo.reset()

    def __reg_sel(self, address):
        if address == self.startAddress + 0:
            return 1
        elif address == self.startAddress + 1:
            return 2
        elif address == self.startAddress + 2:
            return 3
        elif address == self.startAddress + 3:
            return 4
        else:
            return 0

class fifo():
    def __init__(self):

        self.data = [0] * 32
        self.count = 0

    def write(self, value):
        if self.check_full() == False:
            self.data[self.count] = value
            self.count = self.count + 1

    def read(self):
        if self.check_empty() == False:
            self.count = self.count - 1
            value = self.data[0]
            self.__move_fifo_left()
            return value
        else:
            return 0

    def check_full(self):
        if self.count == 32:
            return True
        else:
            return False

    def check_half(self):
        if self.count == 16:
            return True
        else:
            return False

    def check_empty(self):
        if self.count == 0:
            return True
        else:
            return False

    def __move_fifo_left(self):
        for i in range(31):
            self.data[i] = self.data[i + 1]

    def reset(self):
        self.data = [0] * 32
        self.count = 0
