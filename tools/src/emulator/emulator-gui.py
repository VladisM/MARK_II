#!/usr/bin/env python
# -*- coding: utf-8 -*-

from cpu.MARK import MARK
from args import *
from version import *

import sys

import Tkinter as tk

class mainWindow(tk.Frame):
    def __init__(self, master=None):
        tk.Frame.__init__(self, master)
        self.grid()

        self.createVariables()
        self.createWidgets()

        self.soc = MARK(globalDefs.rom0eif, globalDefs.uart0map)

        self.updateRegs()


    def createVariables(self):
        self.r0v = tk.StringVar()
        self.r1v = tk.StringVar()
        self.r2v = tk.StringVar()
        self.r3v = tk.StringVar()
        self.r4v = tk.StringVar()
        self.r5v = tk.StringVar()
        self.r6v = tk.StringVar()
        self.r7v = tk.StringVar()
        self.r8v = tk.StringVar()
        self.r9v = tk.StringVar()
        self.r10v = tk.StringVar()
        self.r11v = tk.StringVar()
        self.r12v = tk.StringVar()
        self.r13v = tk.StringVar()
        self.r14v = tk.StringVar()
        self.r15v = tk.StringVar()

    def createWidgets(self):

        #frames
        self.regframe = tk.LabelFrame(self, text="Registers")
        self.regframe.grid(column=0, row=0)

        self.controlframe = tk.LabelFrame(self, text="Control")
        self.controlframe.grid(column=0, row=1)

        #control buttons
        self.controlframe.tickbutton = tk.Button(self.controlframe, text="Tick", width=6, command=self.tickButton_callback)
        self.controlframe.tickbutton.grid(column=0, row=0)

        self.controlframe.tickbutton = tk.Button(self.controlframe, text="Reset", width=6,  command=self.resetButton_callback)
        self.controlframe.tickbutton.grid(column=1, row=0)

        self.controlframe.tickbutton = tk.Button(self.controlframe, text="Exit", width=6,  command=self.exitButton_callback)
        self.controlframe.tickbutton.grid(column=2, row=0)

        #registers
        self.regframe.labelr0 = tk.Label(self.regframe, text="R0:")
        self.regframe.labelr0.grid(column=0, row=0)

        self.regframe.labelr1 = tk.Label(self.regframe, text="R1:")
        self.regframe.labelr1.grid(column=0, row=1)

        self.regframe.labelr2 = tk.Label(self.regframe, text="R2:")
        self.regframe.labelr2.grid(column=0, row=2)

        self.regframe.labelr3 = tk.Label(self.regframe, text="R3:")
        self.regframe.labelr3.grid(column=0, row=3)

        self.regframe.labelr4 = tk.Label(self.regframe, text="R4:")
        self.regframe.labelr4.grid(column=0, row=4)

        self.regframe.labelr5 = tk.Label(self.regframe, text="R5:")
        self.regframe.labelr5.grid(column=0, row=5)

        self.regframe.labelr6 = tk.Label(self.regframe, text="R6:")
        self.regframe.labelr6.grid(column=0, row=6)

        self.regframe.labelr7 = tk.Label(self.regframe, text="R7:")
        self.regframe.labelr7.grid(column=0, row=7)

        self.regframe.labelr8 = tk.Label(self.regframe, text="R8:")
        self.regframe.labelr8.grid(column=2, row=0)

        self.regframe.labelr9 = tk.Label(self.regframe, text="R9:")
        self.regframe.labelr9.grid(column=2, row=1)

        self.regframe.labelr10 = tk.Label(self.regframe, text="R10:")
        self.regframe.labelr10.grid(column=2, row=2)

        self.regframe.labelr11 = tk.Label(self.regframe, text="R11:")
        self.regframe.labelr11.grid(column=2, row=3)

        self.regframe.labelr12 = tk.Label(self.regframe, text="R12:")
        self.regframe.labelr12.grid(column=2, row=4)

        self.regframe.labelr13 = tk.Label(self.regframe, text="R13:")
        self.regframe.labelr13.grid(column=2, row=5)

        self.regframe.labelr14 = tk.Label(self.regframe, text="R14:")
        self.regframe.labelr14.grid(column=2, row=6)

        self.regframe.labelr15 = tk.Label(self.regframe, text="R15:")
        self.regframe.labelr15.grid(column=2, row=7)

        self.regframe.entryr0 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r0v)
        self.regframe.entryr0.grid(column=1, row=0)

        self.regframe.entryr1 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r1v)
        self.regframe.entryr1.grid(column=1, row=1)

        self.regframe.entryr2 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r2v)
        self.regframe.entryr2.grid(column=1, row=2)

        self.regframe.entryr3 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r3v)
        self.regframe.entryr3.grid(column=1, row=3)

        self.regframe.entryr4 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r4v)
        self.regframe.entryr4.grid(column=1, row=4)

        self.regframe.entryr5 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r5v)
        self.regframe.entryr5.grid(column=1, row=5)

        self.regframe.entryr6 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r6v)
        self.regframe.entryr6.grid(column=1, row=6)

        self.regframe.entryr7 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r7v)
        self.regframe.entryr7.grid(column=1, row=7)

        self.regframe.entryr8 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r8v)
        self.regframe.entryr8.grid(column=3, row=0)

        self.regframe.entryr9 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r9v)
        self.regframe.entryr9.grid(column=3, row=1)

        self.regframe.entryr10 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r10v)
        self.regframe.entryr10.grid(column=3, row=2)

        self.regframe.entryr11 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r11v)
        self.regframe.entryr11.grid(column=3, row=3)

        self.regframe.entryr12 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r12v)
        self.regframe.entryr12.grid(column=3, row=4)

        self.regframe.entryr13 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r13v)
        self.regframe.entryr13.grid(column=3, row=5)

        self.regframe.entryr14 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r14v)
        self.regframe.entryr14.grid(column=3, row=6)

        self.regframe.entryr15 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r15v)
        self.regframe.entryr15.grid(column=3, row=7)

    def tickButton_callback(self):
        self.soc.tick()
        self.updateRegs()

    def resetButton_callback(self):
        self.soc.reset()
        self.updateRegs()

    def exitButton_callback(self):
        del self.soc
        self.quit()

    def updateRegs(self):
        self.r0v.set( "0x" + (hex(int(self.soc.cpu0.regs[0])).split('x')[1]).zfill(8) )
        self.r1v.set( "0x" + (hex(int(self.soc.cpu0.regs[1])).split('x')[1]).zfill(8) )
        self.r2v.set( "0x" + (hex(int(self.soc.cpu0.regs[2])).split('x')[1]).zfill(8) )
        self.r3v.set( "0x" + (hex(int(self.soc.cpu0.regs[3])).split('x')[1]).zfill(8) )
        self.r4v.set( "0x" + (hex(int(self.soc.cpu0.regs[4])).split('x')[1]).zfill(8) )
        self.r5v.set( "0x" + (hex(int(self.soc.cpu0.regs[5])).split('x')[1]).zfill(8) )
        self.r6v.set( "0x" + (hex(int(self.soc.cpu0.regs[6])).split('x')[1]).zfill(8) )
        self.r7v.set( "0x" + (hex(int(self.soc.cpu0.regs[7])).split('x')[1]).zfill(8) )
        self.r8v.set( "0x" + (hex(int(self.soc.cpu0.regs[8])).split('x')[1]).zfill(8) )
        self.r9v.set( "0x" + (hex(int(self.soc.cpu0.regs[9])).split('x')[1]).zfill(8) )
        self.r10v.set( "0x" + (hex(int(self.soc.cpu0.regs[10])).split('x')[1]).zfill(8) )
        self.r11v.set( "0x" + (hex(int(self.soc.cpu0.regs[11])).split('x')[1]).zfill(8) )
        self.r12v.set( "0x" + (hex(int(self.soc.cpu0.regs[12])).split('x')[1]).zfill(8) )
        self.r13v.set( "0x" + (hex(int(self.soc.cpu0.regs[13])).split('x')[1]).zfill(8) )
        self.r14v.set( "0x" + (hex(int(self.soc.cpu0.regs[14])).split('x')[1]).zfill(8) )
        self.r15v.set( "0x" + (hex(int(self.soc.cpu0.regs[15])).split('x')[1]).zfill(8) )


def main():
    get_args()
    print "MARK-II GUI emulator " + version
    print "UART0 mapped into \"" + globalDefs.uart0map + "\""
    print "ROM0 loaded with \"" + globalDefs.rom0eif + "\""

    app = mainWindow()
    app.mainloop()


if __name__ == '__main__':
    main()
