#!/bin/bash

root="/home/savchenk/work"
proot="/home/savchenk/work/dda/dda-ddosa"
daroot="/home/savchenk/work/dda/data-analysis"

export PYTHONPATH=$daroot:$proot:$PYTHONPATH:$PWD:/home/savchenk/work/luigi/dda-luigi:/home/savchenk/work/luigi/ddosa-luigi:/home/savchenk/work/dda/dda-mosaic/:/home/savchenk/work/dda/dda-process_isgri_spectra:/home/savchenk/work/dda/dda-useresponse
export PYTHONPATH=/home/savchenk/work/dda/dda-osahk/:$PYTHONPATH
export PATH=/opt/data-analysis/tools:$PATH
mkdir -p /data/rep_base_prod/scw


cd /home/integral
source heasoft_init.sh
source osa10.2_init.sh
source osa10.2_preparedata.sh
source common_integral_software_init.sh
export COMMON_INTEGRAL_SOFTDIR=$HOME/software/ # no both?

source heasoft_init.sh
#sh setup_curlftpfs.sh



#curlftpfs -o nonempty ftp://isdcarc.unige.ch/arc/rev_3/aux/ /data/rep_base_prod/aux
#curlftpfs -o nonempty ftp://isdcarc.unige.ch/arc/rev_3/scw/ /data/rep_base_prod/scw

echo "mounting.."

sshfs savchenk@isdc-nx01.isdc.unige.ch:/isdc/arc/rev_3/scw /data/rep_base_prod/scw -o IdentityFile=$PWD/keys/datakey -o nonempty -o StrictHostKeyChecking=no
sshfs savchenk@isdc-nx01.isdc.unige.ch:/isdc/arc/rev_3/aux /data/rep_base_prod/aux -o IdentityFile=$PWD/keys/datakey -o nonempty -o StrictHostKeyChecking=no
sshfs savchenk@isdc-nx01.isdc.unige.ch:/isdc/arc/rev_3/cat /data/rep_base_prod/cat -o IdentityFile=$PWD/keys/datakey -o nonempty -o StrictHostKeyChecking=no
sshfs savchenk@isdc-nx01.isdc.unige.ch:/home/isdc/savchenk/osa11_deployment/deployment/ic/ic /data/ic_tree_current/ic -o IdentityFile=$PWD/keys/datakey -o nonempty -o StrictHostKeyChecking=no
sshfs savchenk@isdc-nx01.isdc.unige.ch:/home/isdc/savchenk/osa11_deployment/deployment/ic/idx /data/ic_tree_current/idx -o IdentityFile=$PWD/keys/datakey -o nonempty -o StrictHostKeyChecking=no
sshfs savchenk@isdc-nx01.isdc.unige.ch:/home/isdc/savchenk/osa11_deployment/deployment/ic/ic /data/rep_base_prod/ic -o IdentityFile=$PWD/keys/datakey -o nonempty -o StrictHostKeyChecking=no
sshfs savchenk@isdc-nx01.isdc.unige.ch:/home/isdc/savchenk/osa11_deployment/deployment/ic/idx /data/rep_base_prod/idx -o IdentityFile=$PWD/keys/datakey -o nonempty -o StrictHostKeyChecking=no
#sshfs savchenk@isdc-nx01.isdc.unige.ch:/isdc/arc/rev_3/ic /data/ic_tree_current/ic -o IdentityFile=$PWD/keys/datakey -o nonempty -o StrictHostKeyChecking=no
#sshfs savchenk@isdc-nx01.isdc.unige.ch:/isdc/arc/rev_3/idx /data/ic_tree_current/idx -o IdentityFile=$PWD/keys/datakey -o nonempty -o StrictHostKeyChecking=no



ls /data/rep_base_prod/scw/0665

ls -l /data/ic_tree_current/ic/ibis/mod/isgr_mask_mod_0003.fits

#sshuttle -D  -r savchenk@86.119.32.161 192.168.0.0/24 86.119.34.63 

#ls -l /data/rep_base_prod/scw/0665/066500230010.001

export LUIGI_CONFIG_PATH="/home/savchenk/work/dockers/docker-integral-osa-testing/luigi-config/client.cfg"

ls -l $COMMON_INTEGRAL_SOFTDIR/imaging/varmosaic/varmosaic_exposure/varmosaic

export OPENID_TOKEN_FILE="/home/savchenk/work/sdsc/sdsc/gettoken/token"

PYTHONPATH=$PWD:$PWD/..:$PYTHONPATH
export DISPLAY=""

echo "pythonpath $PYTHONPATH"
echo "in $PWD"

