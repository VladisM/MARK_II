MARK II SoC
====================

This project is under hard development. For more information, send me an email.

MARK II is system on chip written in VHDL, it have custom 32bit CPU and few peripherials.
Also there is a few tools written in Python.


Project structure
--------------------

 * **src/** source codes of SoC
 * **tools/** tools for development (assembler, linker..)
 * **examples/** examples projects
    * **examples/fpga/** Example SoC project for Quartus 13
    * **examples/sw/** some programs for MARK-II cpu
 * **hw/** hardware related files
    * **hw/ioboard/** Interface board for DE0 Nano


TODO List:
--------------------
- [ ] Write better documentation.
- [ ] SDRAM controller.
- [X] Interface board (VGA, PS2, RS232...).
- [X] Improve support for macros in assembler.
- [ ] Write an emulator.
- [ ] Improve CPU architecture.
