#!/bin/bash

cd toolchain/vbcc/doc/
texi2pdf vbcc.texi
mv vbcc.pdf ../../../vbcc.pdf
rm -rf vbcc.aux vbcc.log vbcc.toc
cd ../../..

cd doc/refman/
make
make clean
mv main.pdf ../../refman.pdf
cd ../..

cd toolchain/spl/
doxygen Doxyfile
cd latex
make all
mv refman.pdf ../../../spl_ref.pdf
cd ..
rm -rf latex
cd ../..

echo "\n\nDone..."
