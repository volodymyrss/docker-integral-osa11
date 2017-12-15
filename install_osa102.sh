#set -ex

export ISDC_ENV=/home/integral/osa
export PATH=$ISDC_ENV/bin:$PATH

builddir=${HOME}/build

export F90=gfortran #f95
export F95=gfortran #f95
export F77=gfortran #f95
export CC="gcc44" # -Df2cFortran"
export CXX="g++44" # -Df2cFortran"
source $HOME/root/bin/thisroot.sh

export LDFLAGS=""

mkdir -pv $builddir/osa102

cd $builddir/osa102
wget http://isdc.unige.ch/integral/download/osa/sw/10.2/osa10.2-source.tar.gz


tar xvzf osa10.2-source.tar.gz

cd osa10.2-source/

unset CFLAGS && unset LDFLAGS && unset CPPFLAGS && unset CXXFLAGS 

./support-sw/makefiles/ac_stuff/configure
make install || echo "fail"

