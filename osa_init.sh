
export ISDC_ENV=/osa

rm -rf $HOME/pfiles
source $ISDC_ENV/bin/isdc_init_env.sh

export INTEGRAL_DDCACHE_ROOT=/data/ddcache
export CURRENT_IC=/data/ic_tree_current
export INTEGRAL_DATA=/data/rep_base_prod
export REP_BASE_PROD=/data/rep_base_prod

export F90=gfortran #f95
export F95=gfortran #f95
export F77=gfortran #f95
export CC="gcc44" # -Df2cFortran"
export CXX="g++44" # -Df2cFortran"
source /root/bin/thisroot.sh

