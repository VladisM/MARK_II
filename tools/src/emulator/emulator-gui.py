#!/usr/bin/env python
# -*- coding: utf-8 -*-

from cpu.MARK import MARK
import sys
from args import *

import Tkinter as tk
import pygubu

class MyApplication(pygubu.TkApplication):

    def __init__(self, master):
        self.soc = MARK(globalDefs.rom0eif, globalDefs.uart0map)
        pygubu.TkApplication.__init__(self, master)

    def _create_ui(self):

        self.builder = builder = pygubu.Builder()
        builder.add_from_file("gui.ui")
        self.mainwindow = builder.get_object("mainFrame", self.master)
        builder.connect_callbacks(self)
        self.set_title("MARK II - GUI emulator")

        self.R0v = builder.get_variable('R0v')
        self.R1v = builder.get_variable('R1v')
        self.R2v = builder.get_variable('R2v')
        self.R3v = builder.get_variable('R3v')
        self.R4v = builder.get_variable('R4v')
        self.R5v = builder.get_variable('R5v')
        self.R6v = builder.get_variable('R6v')
        self.R7v = builder.get_variable('R7v')
        self.R8v = builder.get_variable('R8v')
        self.R9v = builder.get_variable('R9v')
        self.R10v = builder.get_variable('R10v')
        self.R11v = builder.get_variable('R11v')
        self.R12v = builder.get_variable('R12v')
        self.R13v = builder.get_variable('R13v')
        self.R14v = builder.get_variable('R14v')
        self.R15v = builder.get_variable('R15v')

        self.update_regs()

    def tick_button(self):
        self.soc.tick()
        self.update_regs()

    def reset_button(self):
        self.soc.reset()
        self.update_regs()

    def update_regs(self):
        self.R0v.set( "0x" + (hex(int(self.soc.cpu0.regs[0])).split('x')[1]).zfill(8) )
        self.R1v.set( "0x" + (hex(int(self.soc.cpu0.regs[1])).split('x')[1]).zfill(8) )
        self.R2v.set( "0x" + (hex(int(self.soc.cpu0.regs[2])).split('x')[1]).zfill(8) )
        self.R3v.set( "0x" + (hex(int(self.soc.cpu0.regs[3])).split('x')[1]).zfill(8) )
        self.R4v.set( "0x" + (hex(int(self.soc.cpu0.regs[4])).split('x')[1]).zfill(8) )
        self.R5v.set( "0x" + (hex(int(self.soc.cpu0.regs[5])).split('x')[1]).zfill(8) )
        self.R6v.set( "0x" + (hex(int(self.soc.cpu0.regs[6])).split('x')[1]).zfill(8) )
        self.R7v.set( "0x" + (hex(int(self.soc.cpu0.regs[7])).split('x')[1]).zfill(8) )
        self.R8v.set( "0x" + (hex(int(self.soc.cpu0.regs[8])).split('x')[1]).zfill(8) )
        self.R9v.set( "0x" + (hex(int(self.soc.cpu0.regs[9])).split('x')[1]).zfill(8) )
        self.R10v.set( "0x" + (hex(int(self.soc.cpu0.regs[10])).split('x')[1]).zfill(8) )
        self.R11v.set( "0x" + (hex(int(self.soc.cpu0.regs[11])).split('x')[1]).zfill(8) )
        self.R12v.set( "0x" + (hex(int(self.soc.cpu0.regs[12])).split('x')[1]).zfill(8) )
        self.R13v.set( "0x" + (hex(int(self.soc.cpu0.regs[13])).split('x')[1]).zfill(8) )
        self.R14v.set( "0x" + (hex(int(self.soc.cpu0.regs[14])).split('x')[1]).zfill(8) )
        self.R15v.set( "0x" + (hex(int(self.soc.cpu0.regs[15])).split('x')[1]).zfill(8) )


if __name__ == '__main__':

    get_args()

    print "MARK-II emulator is running.\nUART0 mapped into \"" + globalDefs.uart0map + "\".\nTo stop execution use CTRL+C."

    root = tk.Tk()
    app = MyApplication(root)
    app.run()
