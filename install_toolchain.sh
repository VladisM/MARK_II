#!/bin/bash

DIR=~/m2_toolchain

echo "Create directory for toolchain..."
mkdir $DIR

echo "Install toolchain..."

echo "version = \"version $(git rev-parse --short HEAD)\"" > toolchain/m2tools/src/version.py
cp -r toolchain/m2tools/src $DIR/
cp -r toolchain/m2tools/bin $DIR/

echo "Compile vbcc..."
cd toolchain/vbcc
echo "char cg_copyright[]=\"MARK-II code generator version $(git rev-parse --short HEAD) (c) in 2017 by Vladislav Mlejnecký\";"> machines/mark/version.h
mkdir bin
make TARGET=mark bin/vbccmark
cd ../..

echo "Install vbcc..."
mkdir $DIR/vbcc
cp toolchain/vbcc/bin/vbccmark $DIR/vbcc/vbccmark
ln -s ./../vbcc/vbccmark $DIR/bin/m2-vbcc

echo "Clean up after vbcc..."
rm -rf toolchain/vbcc/machines/mark/*.o
rm -rf toolchain/vbcc/machines/mark/dt.h
rm -rf toolchain/vbcc/machines/mark/dt.c
rm -rf toolchain/vbcc/machines/mark/version.h
rm -rf toolchain/vbcc/bin

echo "Temporary change PATH to compile libs"
export PATH=$PATH:$DIR/bin

echo "Install spl..."
mkdir $DIR/spl
cp toolchain/spl/include/*.h $DIR/spl/

echo "Install bsp..."
mkdir $DIR/bsp
mkdir $DIR/bsp/lib
cd toolchain/bsp/
make
cp build/*.o $DIR/bsp/lib
cp include/*.h $DIR/bsp
make clean
cd ../..

echo "Install stdlibc..."
mkdir $DIR/stdlibc
cd toolchain/stdlibc
mkdir build
make
cp build/__startup.o $DIR/stdlibc/
make clean
cd ../..

echo "\n\nDone!\n"
echo "You have to add following path into your PATH variable:"
echo $DIR/bin
echo "SPL is stored in:"
echo $DIR/spl/
echo "BPS is stored in:"
echo $DIR/bsp/
echo "stdlibc is stored in:"
echo $DIR/stdlibc/
