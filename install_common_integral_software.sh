#!/bin/bash

source $HOME/osa10.2_init.sh
source $HOME/heasoft_init.sh
source $HOME/common_integral_software_init.sh

mkdir -p $COMMON_INTEGRAL_SOFTDIR
cd $COMMON_INTEGRAL_SOFTDIR

target=imaging/varmosaic/varmosaic_exposure
mkdir -pv $target
cd $target

git clone git@github.com:volodymyrss/varmosaic.git .
cd varmosaic_exposure
git checkout exposure
git reset --hard 261be6a6

hmake
