# Examples

In this directory are listed some simple examples of working with MARK-II
peripherals from C using SPL.

Each source file is heavily commented for explaining how to use individual
features.

## Usage

Prepare your DE0 Nano with MARK-II SoC programmed in FPGA. Connect it to
computer using USB2uart converter, change directory to example you like, set
right port in makefile, and then use:

    $ make
    $ make load

Remember, before `make load` you have to reset MARK-II to start bootloader in
rom0 otherwise you will not be able to connect.


## List of examples:

* **blink/** - blink with LEDs on PORTA
* **uart/**  - write some text on uart console
* **vga/**   - print hello world on the screen

