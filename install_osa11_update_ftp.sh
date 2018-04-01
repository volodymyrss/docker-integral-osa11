#!/bin/bash

#set -xe

filter=${1:-'.*'}

source $HOME/heasoft_init.sh
source $HOME/osa10.2_init.sh 
source $HOME/common_integral_software_init.sh

builddir=${PWD}/build
mkdir -pv ${builddir}
cd ${builddir}

cat > $builddir/osa11_components <<HERE
dal3ibis
ibis_isgr_energy
ibis_comp_energy
barycent
ibis_correction
ibis_scripts
ii_context
ii_light
ii_shadow_build
ii_shadow_ubc
spe_pick
j_ima_iros
j_scripts
rmf-templates
templates-all
test-ibis_isgr_energy
test-ii_shadow_build
test-jemx_image
HERE

for component in `cat $builddir/osa11_components | egrep "$filter"`; do
    (
        mkdir -pv $component
        cd $component
        pwd
        wget ftp://isdcarc.unige.ch/arc/FTP/arc_distr/OSA11_test/components/$component*.tar.gz
        tar xvzf $component*tar.gz

        $ISDC_ENV/ac_stuff/configure
        pwd
        ls -ltor
        make && \
        make install || exit 1
    )
done


