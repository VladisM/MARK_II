MARK II SoC
====================

MARK II is system on chip written in VHDL, it have custom 32bit CPU and few custom peripherals.
Also there is full featured toolchain including assembler, linker, emulator, c compiler and serial
port loader.

Installation & Usage
--------------------

* Clone this repository.
* If you know, what you are doing, checkout master branch, otherwise checkout version you want.
* Build, print and read at least reference manual. Use compile_doc.sh script.
* Build toolchain with install_toolchain.sh script. Run script and follow instructions.
    * Path to SPL is important for vbcc compiler.
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
    * **vbcc/** ISO C compiler with MARK-II backend.
    * **spl/** Standard peripheral library.
* **doc/** Documentation for MARK-II.
    * **refman/** Reference manual directory.

License
--------------------

Whole project, except reference manual and vbcc, is licensed under MIT license.
See /LICENSE for mode details. Reference manual is licensed under Creative
Commons Attribution-NonCommercial 4.0 International License. The vbcc compiler
is licensed by  Dr. Volker Barthelmann, full license can be found in vbcc
documentation. MARK II backend for vbcc is licensed under MIT too.
