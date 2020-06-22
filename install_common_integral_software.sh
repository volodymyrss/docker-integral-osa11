#!/bin/bash

source /osa_init.sh
source /heasoft_init.sh
source /common_integral_software_init.sh

mkdir -p $COMMON_INTEGRAL_SOFTDIR
cd $COMMON_INTEGRAL_SOFTDIR

target=imaging/varmosaic/varmosaic_exposure
mkdir -pv $target
cd $target

git clone https://github.com/volodymyrss/varmosaic.git .
cd varmosaic_exposure
git checkout exposure
git reset --hard 261be6a6

hmake
