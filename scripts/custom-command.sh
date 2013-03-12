#!/bin/bash

#   ***************************************************************************
#     build-apk.sh - builds the and installs the needed libraries for android QGIS
#      --------------------------------------
#      Date                 : 01-Aug-2011
#      Copyright            : (C) 2011 by Marco Bernasocchi
#      Email                : marco at bernawebdesign.ch
#   ***************************************************************************
#   *                                                                         *
#   *   This program is free software; you can redistribute it and/or modify  *
#   *   it under the terms of the GNU General Public License as published by  *
#   *   the Free Software Foundation; either version 2 of the License, or     *
#   *   (at your option) any later version.                                   *
#   *                                                                         *
#   ***************************************************************************/

set -e

source `dirname $0`/config.conf

#$ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh --platform=$ANDROID_NDK_PLATFORM --install-dir=$ANDROID_STANDALONE_TOOLCHAIN --toolchain=arm-linux-androideabi-$ANDROID_NDK_TOOLCHAIN_VERSION

 ########GEOS#######
#  echo "$GEOS_NAME"
#  cd $SRC_DIR
#  svn checkout http://svn.osgeo.org/geos/tags/$GEOS_VERSION/  $GEOS_NAME
#  wget -c http://download.osgeo.org/geos/$GEOS_NAME.tar.bz2
#  tar xjf $GEOS_NAME.tar.bz2
#  cd libgeos/
#  cp -vf $TMP_DIR/config.sub ./config.sub
#  cp -vf $TMP_DIR/config.guess ./config.guess
#  #GET and apply patch for http://trac.osgeo.org/geos/ticket/534
##  wget -c http://trac.osgeo.org/geos/raw-attachment/ticket/534/int64_crosscomp.patch
##  patch -i int64_crosscomp.patch -p1
##  #GET and apply patch for http://trac.osgeo.org/geos/ticket/222
##  wget -c http://trac.osgeo.org/geos/raw-attachment/ticket/222/$GEOS_NAME-ARM.patch -O $GEOS_NAME-ARM.bug222.patch
##  patch -i $GEOS_NAME-ARM.bug222.patch -p0
##  ./autogen.sh
##  patch -i $PATCH_DIR/geos.patch -p1
#  #######END GEOS#######
#  exit
  
#########GEO####
#echo "$GEOS_NAME"
#cd $SRC_DIR/
#wget -c http://download.osgeo.org/geos/$GEOS_NAME.tar.bz2
#tar xjf $GEOS_NAME.tar.bz2
#cd $GEOS_NAME/
#cp -vf $TMP_DIR/config.sub ./config.sub
#cp -vf $TMP_DIR/config.guess ./config.guess
#patch -i $PATCH_DIR/geos.patch
#mkdir -p build-$ANDROID_ABI
#cd build-$ANDROID_ABI
##configure
#CFLAGS="$MY_STD_CFLAGS" \
#CXXFLAGS="$MY_STD_CXXFLAGS" \
#LDFLAGS=$MY_STD_LDFLAGS \
#../configure $MY_STD_CONFIGURE_FLAGS
##compile
#make -j$CORES 2>&1 | tee make.out
#make -j$CORES 2>&1 install | tee makeInstall.out
