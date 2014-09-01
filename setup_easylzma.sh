#!/usr/bin/env sh

git clone git://github.com/lloyd/easylzma
cd easylzma
mkdir build
cd build
cmake ..
make
ln -s easylzma-* easylzma

