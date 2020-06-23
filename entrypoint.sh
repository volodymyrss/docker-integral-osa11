#!/bin/bash

export WORKDIR=/scratch/$HOSTNAME/
mkdir -pv $WORKDIR/tmp-home

export HOME_OVERRRIDE=$WORKDIR/tmp-home

source /init.sh
#sh setup_curlftpfs.sh

set -x

cd $HOME

#cp -fvr  /data/resources /data/rep_base_prod/resources

export COMMON_INTEGRAL_SOFTDIR=$HOME/software/
export PYTHONUNBUFFERED=0
export DISPLAY=""

#export CONTAINER_NAME=`python get_docker_name.py`
export CONTAINER_NAME=$HOSTNAME


[ "$MATTERMOST_CHANNEL" == "" ] || (echo "starting backend master $CONTAINER_NAME " | mattersend  -U `cat ~/.mattermost-hook` -c $MATTERMOST_CHANNEL)

#sh choose_proxy.sh

cd $WORKDIR

export PFILES="$PWD/pfiles;${PFILES##*;}"

mkdir -pv $PWD/pfiles

#ln -s /osa  /home/integral/osa

echo "worker mode: $WORKER_MODE"
if [ "$WORKER_MODE" == "interface" ]; then
#resttimesystem.sh > /host_var/log/resttimesystem.log 2>&1
    while true; do
        echo "interface worker starting"
        DISPLAY="" gunicorn --log-level debug -b 0.0.0.0:8000 ddaworker.service:app 2>&1 
        echo "worker dead: restarting"
        sleep 1
    done | tee -a /var/log/containers/${CONTAINER_NAME}
else
    while true; do
        echo "passive worker starting"
        DISPLAY="" python -m dataanalysis.caches.queue $DDA_QUEUE 2>&1
        echo "worker dead: restarting"
        sleep 1
    done | tee -a /var/log/containers/${CONTAINER_NAME}
fi


