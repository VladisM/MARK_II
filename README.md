MARK II SoC
====================

This project is under hard development. For more information, send me an email.

MARK II is system on chip written in VHDL, it have custom 32bit CPU and few peripherials.
Also there is a few tools written in Python.

Project structure:
--------------------

* **fpga/** All FPGA related things.
    * **project/** Example project for Quartus II 13.0 sp1 and DE0 Nano board.
    * **src/** VHDL codes of whole MARK-II.
* **hw/** All about Hardware. Addons for DE0 Nano board.
* **sw/** MARK-II related software.
    * **m2-tools/** Tools for programming on MARK-II. Emulator, assembler...
    * **loader/** Serial bootloader firmware.

TODO List:
--------------------
- [ ] Write better documentation.
- [ ] SDRAM controller.
- [ ] Improve CPU architecture.
- [ ] Get C compiler.
