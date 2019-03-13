#!/bin/bash

cd /home/integral
source /osa_init.sh

source /heasoft_init.sh
#sh setup_curlftpfs.sh

cp -fvr  /data/resources /data/rep_base_prod/resources

export COMMON_INTEGRAL_SOFTDIR=$HOME/software/
export PYTHONUNBUFFERED=0
export DISPLAY=""

#export CONTAINER_NAME=`python get_docker_name.py`
export CONTAINER_NAME=$HOSTNAME


[ "$MATTERMOST_CHANNEL" == "" ] || (echo "starting backend master $CONTAINER_NAME " | mattersend  -U `cat ~/.mattermost-hook` -c $MATTERMOST_CHANNEL)

sh choose_proxy.sh

for dev_package in /dev-packages/*; do
    export PYTHONPATH=$dev_package:$PYTHONPATH
    echo "adding dev package: $PYTHONPATH"
done

export WORKDIR=/scratch/$HOSTNAME/
mkdir -pv $WORKDIR
cd $WORKDIR

export PFILES="$PWD;${PFILES##*;}"

ln -s /osa11  /home/integral/osa

if [ "$mode" == "interface" ]; then
#resttimesystem.sh > /host_var/log/resttimesystem.log 2>&1
    while true; do
        DISPLAY="" python -m restddosaworker 2>&1 
        echo "worker dead: restarting"
    done | tee -a /var/log/containers/${CONTAINER_NAME}
else
    while true; do
        DISPLAY="" python -m dataanalysis.caches.queue $DDA_QUEUE 2>&1
        echo "worker dead: restarting"
    done | tee -a /var/log/containers/${CONTAINER_NAME}
fi


