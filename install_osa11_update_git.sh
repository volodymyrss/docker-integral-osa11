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
    echo "will build $component"
    cd $builddir
    git clone git@github.com:volodymyrss/osa-${component}.git osa-${component}
    cd osa-${component}
    pwd
    cat component.yaml
    $HOME/osa-builder/component_templating.py patch dev || exit 1
    $ISDC_ENV/ac_stuff/configure
    pwd
    ls -ltor
    make && \
    make install || exit 1
    [ -s ${component}-version.sh ] && cp -fv ${component}-version.sh $ISDC_ENV/bin/
done


