#!/bin/bash

#set -x

source $HOME/osa10.2_init.sh
source $HOME/heasoft_init.sh
source $HOME/common_integral_software_init.sh

mkdir -p $COMMON_INTEGRAL_SOFTDIR
cd $COMMON_INTEGRAL_SOFTDIR

git clone git@github.com:volodymyrss/osa-ii_context.git ii_context
cd ii_context
git reset --hard e59363c

$ISDC_ENV/ac_stuff/configure

pwd
ls -ltor
make
