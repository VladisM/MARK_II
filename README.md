MARK II SoC
====================

MARK II is system on chip written in VHDL, it have custom 32bit CPU and few peripherals.
Also there is a few tools written in Python.

Installation & Usage
--------------------

* Clone this repository and make sure you are on master branch.
* Merge branch bugfixs.
* Build and print and read reference manual from /doc/refman.
* Place /sw/m2-tools somewhere (eg. in /opt/m2tools) and add bin directory to your $PATH.
* Write your code, compile it, load it, run it and enjoy!

Project structure:
--------------------

* **fpga/** All FPGA related things.
    * **project/** Example project for Quartus II 13.0 sp1 and DE0 Nano board.
    * **src/** VHDL codes of whole MARK-II.
* **hw/** All about Hardware. Addons for DE0 Nano board.
* **sw/** MARK-II related software.
    * **m2-tools/** Tools for programming on MARK-II. Emulator, assembler...
    * **loader/** Serial bootloader firmware.
    * **tests/** Some old test programs.
    * **stdio/** Simple STDIO library for UART and text operations.
* **doc/** Documentation for MARK-II.
    * **refman/** Reference manual directory.
