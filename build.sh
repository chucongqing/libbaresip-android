#!/bin/bash

pwd=/home/chucongqing/dev/xyt/libbaresip-android
cd $pwd && make libre.a && make libbaresip

if [ $? -eq 0 ]; then
rm -f gdist.zip ; zip -r gdist.zip distribution.video
else 
echo "build failed"
fi


