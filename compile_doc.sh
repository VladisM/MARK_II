#!/bin/bash

cd sw/vbcc/doc/
texi2pdf vbcc.texi
mv vbcc.pdf ../../../vbcc.pdf
rm -rf vbcc.aux vbcc.log vbcc.toc
cd ../../..

cd doc/refman/
make
make clean
mv main.pdf ../../refman.pdf
cd ../..

echo "\n\nDone..."
