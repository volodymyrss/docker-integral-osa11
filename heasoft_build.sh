#!/bin/bash

version=6.22.1 # or set docker arg
install_prefix=/home/integral/heasoft/
url=http://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft${version}/heasoft-${version}src_no_xspec_modeldata.tar.gz
gzFile=`basename $url`

#---------------------------------------------
# download
#---------------------------------------------
if [ ! -f $gzFile ]; then
    echo "Downloading..."
    wget $url
fi

if [ ! -f $gzFile ]; then
    echo "Download failed."
    exit -1
fi


#---------------------------------------------
# unzip/tar xf
#---------------------------------------------

tar zvxf $gzFile

#---------------------------------------------
# configure/make/make install
#---------------------------------------------

cd $HOME
cd heasoft-${version}/BUILD_DIR

echo "Configuring... (message saved in log_configure)"
./configure --prefix=${install_prefix} 2>&1 > log_configure

echo "Executing make (message saved in log_make)"
make 2>&1 #> log_make

echo "Executing make install (message saved in log_make_install)"
make install 2>&1 #> ~/heasoft_log_make_install

cd $HOME

rm -rfv heasoft-${version}/ $gzfile
rm -fv *gz
find heasoft -size +5M | grep ref | xargs rm -fv
