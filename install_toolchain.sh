#!/bin/bash

DIR=~/m2toolchain

echo "Create directory for toolchain..."
mkdir $DIR

echo "Install toolchain..."
cp -r sw/m2tools/src $DIR/
cp -r sw/m2tools/bin $DIR/

echo "Compile vbcc..."
cd sw/vbcc
mkdir bin
make TARGET=mark bin/vbccmark
cd ../..

echo "Install vbcc..."
mkdir $DIR/vbcc
cp sw/vbcc/bin/vbccmark $DIR/vbcc/vbccmark
ln -s ./../vbcc/vbccmark $DIR/bin/m2-vbcc

echo "Clean up after vbcc..."
rm -rf sw/vbcc/machines/mark/*.o
rm -rf sw/vbcc/machines/mark/dt.h
rm -rf sw/vbcc/machines/mark/dt.c
rm -rf sw/vbcc/bin

echo "Install spl..."
mkdir $DIR/spl
cp -r sw/spl/*.h $DIR/spl/

echo "\n\nDone!\n"
echo "You have to add following path into your PATH variable:"
echo $DIR/bin
echo "SPL are stored in:"
echo $DIR/spl/
