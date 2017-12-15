#!/bin/bash

cd /home/integral
source osa10.2_init.sh
source osa10.2_preparedata.sh

source heasoft_init.sh
#sh setup_curlftpfs.sh

export COMMON_INTEGRAL_SOFTDIR=$HOME/software/
export PYTHONUNBUFFERED=0

#resttimesystem.sh > /host_var/log/resttimesystem.log 2>&1


cd /home/integral
jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 &

python -u -m restddosaworker #> /host_var/log/restddosaworker.log 2>&1
