#!/bin/sh
#
set -e
#############################
#######CONFIGURE HERE########
#############################
export ROOT_DIR=$HOME/dev/qgis-mobile
export INSTALL_DIR=$HOME/apps/qgis-mobile/libs
export SRC_DIR=$ROOT_DIR/libs
export TMP_DIR=$ROOT_DIR/tmp
export SCRIPTS_DIR=$ROOT_DIR/scripts
export NDK=$HOME/necessitas/android-ndk-r5b
#############################
#######END CONFIGURE#########
#############################
#
echo "Downloading src to: " $SRC_DIR
echo "Installing to: " $INSTALL_DIR
echo "NDK location: " $NDK
#
CONTINUE=n
echo "OK? [y, n*]:"
read CONTINUE
CONTINUE=$(echo $CONTINUE | tr "[:lower:]" "[:upper:]")
if [ "$CONTINUE" = "Y" ]; then
continue
else
echo "Abort"
exit
fi

export NDK_PLATFORM=$NDK/platforms/android-4/arch-arm
#detect cpu cores
export CORES=$(cat /proc/cpuinfo | grep processor | wc -l)

mkdir -p $TMP_DIR
#Get Updated config.sub
wget "http://git.savannah.gnu.org/gitweb/?p=autoconf.git;a=blob_plain;f=build-aux/config.sub;hb=7420ce3483ec7d50de0667ec03b86be143f72c52" -O $TMP_DIR/config.sub

#FIXME
#diff $NDK_PLATFORM/usr/include/sys/types.h.orig $NDK_PLATFORM/usr/include/sys/types.h
#124c124
#< typedef uint64_t       u_int64_t;
#---
#
#> //typedef uint64_t       u_int64_t;

mkdir -p $SRC_DIR
cd $SRC_DIR

#PROJ4
$SCRIPTS_DIR/proj-4.7.0.sh
#END PROJ4
#GEOS3.2.2
$SCRIPTS_DIR/geos-3.2.2.sh
#END GEOS3.2.2
