vbcc - C compiler with MARK-II backend
==============

vbcc is portable ISO C compiler wrote by Dr. Volker Barthelmann. In this
directory  you can found full unmodified source of vbcc with MARK-II backend
added.

There is [link](http://www.compilers.de/vbcc.html) to vbcc homepage.

Many thanks to Dr. Volker Bertelmann for simple retargetable compiler.

License
--------------


Please note: vbcc is licensed by Dr. Volker Barthelmann, you can found full
license in vbcc documentation.

My work is only backed, namely these files:

* machines/mark/machine.c
* machines/mark/machine.h
* machines/mark/machine.dt

These three files are licensed under MIT license.

Compiling
--------------

Compiling is simple, just create directory bin and evaluate make like this:

    $ pwd
    ~/MARK_II/sw/vbcc/
    $ mkdir bin/
    $ make TARGET=mark bin/vbccmark

For more information please see vbcc documentation.

Documentation
--------------

Original documentation is located in doc folder. You can compile it using, for
example, texi2pdf. Simple invoke:

    $ texi2pdf vbcc.texi
