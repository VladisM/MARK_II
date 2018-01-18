# MARK-II SoC

MARK II is system on chip written in VHDL, it have custom 32bit CPU and 
few custom peripherals. Also there is full featured toolchain including 
assembler, linker, emulator, c compiler and serial port loader.

## Prerequisites
	
* Any common Linux distribution
* git
* texi2pdf
* pdflatex
* doxygen
* gcc
* python 2.7
* make
* quartus

## Get more documentation

In order to get more documentation, for example reference manual for 
SoC, one can use script in root of this repository called 
`compile_doc.sh`. This will create set of some PDF files with all 
available documentation.

## Install toolchain

Toolchain can be found in folder `/toolchain`. In order to install it on 
your computer please use script in root of this repository called 
`install_toolchain.sh`.

Please check this script and optionally change value of variable `DIR`. 
In this variable should be an path to existing folder where you want to 
have toolchain installed.

At the end of installation, script will print three paths, first is 
where everything is installed and you should add this path to your PATH 
variable. Others two paths are important for compiler and linker, see 
some of one example in folder `/doc/examples` to see how to work with 
them.

## Project structure:

* **VHDL/** In this directory is all HDL sources for MARK-II SoC.
* **toolchain/** MARK-II toolchain.
* **doc/** Documentation for MARK-II.

## License

Whole project, except reference manual and vbcc, is licensed under MIT 
license. Please see file LICENSE for more details. 

### Reference Manual

Reference manual is licensed under Creative Commons 
Attribution-NonCommercial 4.0 International License. 

### VBCC

Please note: vbcc is licensed by Dr. Volker Barthelmann, you can found 
full license in vbcc documentation.

My work is only backed, namely these files:

* machines/mark/machine.c
* machines/mark/machine.h
* machines/mark/machine.dt

These three files are licensed under MIT license.
