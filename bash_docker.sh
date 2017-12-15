#!/bin/bash

root="/home/savchenk/work"
proot="/home/savchenk/work/dda/dda-ddosa"
daroot="/home/savchenk/work/dda/data-analysis"

cat > cmd.sh <<HERE
source init.sh

echo \$PYTHONPATH

export REP_BASE_ARC=/data/rep_base_prod
export REP_BASE_NRT=/data/rep_base_prod_nrt

cd /home/integral/

bash $@
HERE


docker run --privileged -e PYTHONUNBUFFERED=0 \
    --entrypoint=/bin/bash \
    -v $root:$root:ro \
    -v /opt/data/reduced/ddcache/:/data/ddcache \
    -v /opt/pycharm-community-2017.1.3/:/opt/pycharm-community-2017.1.3/:ro \
    volodymyrsavchenko/docker-integral-osa:osa11 \
     -c "`cat cmd.sh`"

