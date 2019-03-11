#!/bin/bash

cd /home/integral
source osa_init.sh

source heasoft_init.sh
#sh setup_curlftpfs.sh

cp -fvr  /data/resources /data/rep_base_prod/resources

export COMMON_INTEGRAL_SOFTDIR=$HOME/software/
export PYTHONUNBUFFERED=0


#cd /home/integral
#jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 &

python -u -m restddosaworker #> /host_var/log/restddosaworker.log 2>&1
