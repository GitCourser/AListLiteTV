#!/bin/bash

mkdir /tmp/alist-lib
cd ..
cp -r alistlib /tmp/alist-lib
cp -r scripts /tmp/alist-lib

cd ..
rm -rf alist-lib
cp -r /tmp/alist-lib .

rm -rf /tmp/alist-lib