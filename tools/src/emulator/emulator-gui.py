#!/usr/bin/env python
# -*- coding: utf-8 -*-

from cpu.MARK import MARK
from args import *
from version import *

import sys

import Tkinter as tk
import tkFont as tkf

class mainWindow(tk.Frame):
    def __init__(self, master=None):
        tk.Frame.__init__(self, master)
        self.grid()

        self.createVariables()
        self.createWidgets()

        self.soc = MARK(globalDefs.rom0eif, globalDefs.uart0map)

        self.updateRegs()
        self.updateMems()

        self.master.title('MARK-II GUI Emulator')

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
        self.regframe.grid(column=0, row=0, padx=5, pady=2)

        self.controlframe = tk.LabelFrame(self, text="Control")
        self.controlframe.grid(column=1, row=0, padx=5, pady=2, sticky=tk.N)

        self.memFrame = tk.LabelFrame(self, text="Memory")
        self.memFrame.grid(column=0, row=1, columnspan=2, padx=5, pady=2)

        #control buttons
        self.controlframe.tickbutton = tk.Button(self.controlframe, text="Tick", width=6, command=self.tickButton_callback)
        self.controlframe.tickbutton.grid(column=0, row=0, padx=5, pady=2)

        self.controlframe.tickbutton = tk.Button(self.controlframe, text="Reset", width=6,  command=self.resetButton_callback)
        self.controlframe.tickbutton.grid(column=1, row=0, padx=5, pady=2)

        self.controlframe.tickbutton = tk.Button(self.controlframe, text="Exit", width=6,  command=self.exitButton_callback)
        self.controlframe.tickbutton.grid(column=2, row=0, padx=5, pady=2)

        #registers
        self.regframe.labelr0 = tk.Label(self.regframe, text="R0:")
        self.regframe.labelr0.grid(column=0, row=0, padx=5, pady=2)

        self.regframe.labelr1 = tk.Label(self.regframe, text="R1:")
        self.regframe.labelr1.grid(column=0, row=1, padx=5, pady=2)

        self.regframe.labelr2 = tk.Label(self.regframe, text="R2:")
        self.regframe.labelr2.grid(column=0, row=2, padx=5, pady=2)

        self.regframe.labelr3 = tk.Label(self.regframe, text="R3:")
        self.regframe.labelr3.grid(column=0, row=3, padx=5, pady=2)

        self.regframe.labelr4 = tk.Label(self.regframe, text="R4:")
        self.regframe.labelr4.grid(column=0, row=4, padx=5, pady=2)

        self.regframe.labelr5 = tk.Label(self.regframe, text="R5:")
        self.regframe.labelr5.grid(column=0, row=5, padx=5, pady=2)

        self.regframe.labelr6 = tk.Label(self.regframe, text="R6:")
        self.regframe.labelr6.grid(column=0, row=6, padx=5, pady=2)

        self.regframe.labelr7 = tk.Label(self.regframe, text="R7:")
        self.regframe.labelr7.grid(column=0, row=7, padx=5, pady=2)

        self.regframe.labelr8 = tk.Label(self.regframe, text="R8:")
        self.regframe.labelr8.grid(column=2, row=0, padx=5, pady=2)

        self.regframe.labelr9 = tk.Label(self.regframe, text="R9:")
        self.regframe.labelr9.grid(column=2, row=1, padx=5, pady=2)

        self.regframe.labelr10 = tk.Label(self.regframe, text="R10:")
        self.regframe.labelr10.grid(column=2, row=2, padx=5, pady=2)

        self.regframe.labelr11 = tk.Label(self.regframe, text="R11:")
        self.regframe.labelr11.grid(column=2, row=3, padx=5, pady=2)

        self.regframe.labelr12 = tk.Label(self.regframe, text="R12:")
        self.regframe.labelr12.grid(column=2, row=4, padx=5, pady=2)

        self.regframe.labelr13 = tk.Label(self.regframe, text="R13:")
        self.regframe.labelr13.grid(column=2, row=5, padx=5, pady=2)

        self.regframe.labelr14 = tk.Label(self.regframe, text="R14:")
        self.regframe.labelr14.grid(column=2, row=6, padx=5, pady=2)

        self.regframe.labelr15 = tk.Label(self.regframe, text="R15:")
        self.regframe.labelr15.grid(column=2, row=7, padx=5, pady=2)

        self.regframe.entryr0 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r0v)
        self.regframe.entryr0.grid(column=1, row=0, padx=5, pady=2)

        self.regframe.entryr1 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r1v)
        self.regframe.entryr1.grid(column=1, row=1, padx=5, pady=2)

        self.regframe.entryr2 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r2v)
        self.regframe.entryr2.grid(column=1, row=2, padx=5, pady=2)

        self.regframe.entryr3 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r3v)
        self.regframe.entryr3.grid(column=1, row=3, padx=5, pady=2)

        self.regframe.entryr4 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r4v)
        self.regframe.entryr4.grid(column=1, row=4, padx=5, pady=2)

        self.regframe.entryr5 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r5v)
        self.regframe.entryr5.grid(column=1, row=5, padx=5, pady=2)

        self.regframe.entryr6 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r6v)
        self.regframe.entryr6.grid(column=1, row=6, padx=5, pady=2)

        self.regframe.entryr7 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r7v)
        self.regframe.entryr7.grid(column=1, row=7, padx=5, pady=2)

        self.regframe.entryr8 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r8v)
        self.regframe.entryr8.grid(column=3, row=0, padx=5, pady=2)

        self.regframe.entryr9 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r9v)
        self.regframe.entryr9.grid(column=3, row=1, padx=5, pady=2)

        self.regframe.entryr10 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r10v)
        self.regframe.entryr10.grid(column=3, row=2, padx=5, pady=2)

        self.regframe.entryr11 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r11v)
        self.regframe.entryr11.grid(column=3, row=3, padx=5, pady=2)

        self.regframe.entryr12 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r12v)
        self.regframe.entryr12.grid(column=3, row=4, padx=5, pady=2)

        self.regframe.entryr13 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r13v)
        self.regframe.entryr13.grid(column=3, row=5, padx=5, pady=2)

        self.regframe.entryr14 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r14v)
        self.regframe.entryr14.grid(column=3, row=6, padx=5, pady=2)

        self.regframe.entryr15 = tk.Entry(self.regframe, width=10, disabledforeground="#000", disabledbackground="#fff", state=tk.DISABLED, textvariable=self.r15v)
        self.regframe.entryr15.grid(column=3, row=7, padx=5, pady=2)

        #memory view
        self.memFrame.rom0frame = tk.LabelFrame(self.memFrame, text="rom0")
        self.memFrame.rom0frame.grid(column=0, row=0, padx=5, pady=2)

        self.memFrame.rom0frame.rom0 = tk.Text(self.memFrame.rom0frame, width=21, height=16, state=tk.DISABLED)
        self.memFrame.rom0frame.rom0.grid(column=0, row=0)

        self.memFrame.rom0frame.scrollY = tk.Scrollbar(self.memFrame.rom0frame, orient=tk.VERTICAL, command=self.memFrame.rom0frame.rom0.yview)
        self.memFrame.rom0frame.scrollY.grid(row=0, column=1, sticky=tk.N+tk.S)

        self.memFrame.rom0frame.rom0['yscrollcommand'] = self.memFrame.rom0frame.scrollY.set


        self.memFrame.ram0frame = tk.LabelFrame(self.memFrame, text="ram0")
        self.memFrame.ram0frame.grid(column=1, row=0, padx=5, pady=2)

        self.memFrame.ram0frame.ram0 = tk.Text(self.memFrame.ram0frame, width=21, height=16, state=tk.DISABLED)
        self.memFrame.ram0frame.ram0.grid(column=0, row=0)

        self.memFrame.ram0frame.scrollY = tk.Scrollbar(self.memFrame.ram0frame, orient=tk.VERTICAL, command=self.memFrame.ram0frame.ram0.yview)
        self.memFrame.ram0frame.scrollY.grid(row=0, column=1, sticky=tk.N+tk.S)

        self.memFrame.ram0frame.ram0['yscrollcommand'] = self.memFrame.ram0frame.scrollY.set


        self.memFrame.ram1frame = tk.LabelFrame(self.memFrame, text="ram1")
        self.memFrame.ram1frame.grid(column=2, row=0, padx=5, pady=2)

        self.memFrame.ram1frame.ram1 = tk.Text(self.memFrame.ram1frame, width=21, height=16, state=tk.DISABLED)
        self.memFrame.ram1frame.ram1.grid(column=0, row=0)

        self.memFrame.ram1frame.scrollY = tk.Scrollbar(self.memFrame.ram1frame, orient=tk.VERTICAL, command=self.memFrame.ram1frame.ram1.yview)
        self.memFrame.ram1frame.scrollY.grid(row=0, column=1, sticky=tk.N+tk.S)

        self.memFrame.ram1frame.ram1['yscrollcommand'] = self.memFrame.ram1frame.scrollY.set

    def tickButton_callback(self):
        self.soc.tick()
        self.updateRegs()
        self.updateMems()

    def resetButton_callback(self):
        self.soc.reset()
        self.updateRegs()
        self.updateMems()

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

    def updateMems(self):
        self.updateRom0()
        self.updateRam0()
        self.updateRam1()

    def updateRom0(self):
        self.memFrame.rom0frame.rom0['state'] = tk.NORMAL
        self.memFrame.rom0frame.rom0.delete(1.0, tk.END)

        linecounter = 0
        for item in self.soc.rom0.mem:
            address = "0x" + (hex(linecounter).split('x')[1]).zfill(6)
            value = "0x" + (hex(int(self.soc.rom0.mem[linecounter])).split('x')[1]).zfill(8)

            if linecounter != 0:
                self.memFrame.rom0frame.rom0.insert(tk.END, "\n")

            self.memFrame.rom0frame.rom0.insert(tk.END, address + " : " + value)

            linecounter = linecounter + 1

        self.memFrame.rom0frame.rom0['state'] = tk.DISABLED

    def updateRam0(self):
        self.memFrame.ram0frame.ram0['state'] = tk.NORMAL
        self.memFrame.ram0frame.ram0.delete(1.0, tk.END)

        linecounter = 0
        for item in self.soc.ram0.mem:
            address = "0x" + (hex(linecounter + 1024).split('x')[1]).zfill(6)
            value = "0x" + (hex(int(self.soc.ram0.mem[linecounter])).split('x')[1]).zfill(8)

            if linecounter != 0:
                self.memFrame.ram0frame.ram0.insert(tk.END, "\n")

            self.memFrame.ram0frame.ram0.insert(tk.END, address + " : " + value)

            linecounter = linecounter + 1

        self.memFrame.ram0frame.ram0['state'] = tk.DISABLED

    def updateRam1(self):
        self.memFrame.ram1frame.ram1['state'] = tk.NORMAL
        self.memFrame.ram1frame.ram1.delete(1.0, tk.END)

        linecounter = 0
        for item in self.soc.ram1.mem:
            address = "0x" + (hex(linecounter +  1048576).split('x')[1]).zfill(6)
            value = "0x" + (hex(int(self.soc.ram1.mem[linecounter])).split('x')[1]).zfill(8)

            if linecounter != 0:
                self.memFrame.ram1frame.ram1.insert(tk.END, "\n")

            self.memFrame.ram1frame.ram1.insert(tk.END, address + " : " + value)

            linecounter = linecounter + 1

        self.memFrame.ram1frame.ram1['state'] = tk.DISABLED

def main():
    get_args()
    print "MARK-II GUI emulator " + version
    print "UART0 mapped into \"" + globalDefs.uart0map + "\""
    print "ROM0 loaded with \"" + globalDefs.rom0eif + "\""

    app = mainWindow()
    app.mainloop()

if __name__ == '__main__':
    main()
