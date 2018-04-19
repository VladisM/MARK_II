MARK-II Board
=======

This directory contain design files for manufacturing official MARK-II 
Board. 

Board design is done in eagle and is located in *hw\_design*
folder. You can found schematics in pdf format located in this 
directory. 

Firmware for power management IC is in fw directory. You can found 
settings for FT230X in this directory.

![board photo](https://user-images.githubusercontent.com/17781503/38455173-8274c1d6-3a74-11e8-95c2-0bc5e3296400.jpg)


Manufacturing
-----

1. **Get the PCB**

   Find service what will manufacture board for you. It have 4 layers. 
   You can use OSH Park if you wish. Board is designed against their 
   rules.

2. **Get parts and solder them**

   All parts in eagle files have attribute called mouser or farnell. 
   Export BOM and order them.
   
   Once you have all parts, go ahead and solder them. You probably want 
   to use oven or hot air, at least for FPGA, and oscillators.
   
3. **Complete it!**

   Use avr toolchain to compile and load firmware to you power 
   management IC, then use FT_Prog to load FT230X configuration. 
   Finally, compile HDL, generate pof file and configure your FPGA.
   
4. **Enjoy your board!**

   You can load examples, write your own programs, try to fight with 
   OS ... or you can make your custom case!
	
