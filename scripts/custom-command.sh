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


if [ "$ANDROID_TARGET_ARCH" = "armeabi-v7a" ]; then
    #include is needed to fix http://hub.qgis.org/issues/4202
    armV7aHackInclude="-I$ANDROID_NDK_TOOLCHAIN_ROOT/arm-linux-androideabi/include/c++/4.4.3/arm-linux-androideabi/armv7-a"
fi

#  ######GDAL#######
#  echo "GDAL-trunk"
#  cd $SRC_DIR
#  svn checkout https://svn.osgeo.org/gdal/trunk/gdal gdal-trunk
#  cd gdal-trunk/
#  cp -f $TMP_DIR/config.sub ./config.sub
#  cp -f $TMP_DIR/config.guess ./config.guess
#  patch -i $PATCH_DIR/gdal.patch 
##  GDAL does not seem to support building in subdirs
#  cp -vrf $SRC_DIR/gdal-trunk/ $SRC_DIR/gdal-trunk-armeabi/
#  mv -vf $SRC_DIR/gdal-trunk/ $SRC_DIR/gdal-trunk-armeabi-v7a/


  #########GDAL-trunk########
  echo "GDAL trunk"
  cd $SRC_DIR/gdal-trunk-$ANDROID_TARGET_ARCH/
  #configure
  CFLAGS="$MY_STD_CFLAGS $armV7aHackInclude" \
  CXXFLAGS="$MY_STD_CXXFLAGS $armV7aHackInclude" \
  LDFLAGS=$MY_STD_LDFLAGS \
  LIBS="-lsupc++ -lstdc++" \
  ./configure $MY_STD_CONFIGURE_FLAGS
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END GDAL-trunk########


#echo "GDAL"
    #  cd $SRC_DIR/gdal-1.8.0-$ANDROID_TARGET_ARCH/
    #  #configure
    #  CFLAGS="$MY_STD_CFLAGS $armV7aHackInclude" \
    #  CXXFLAGS="$MY_STD_CXXFLAGS $armV7aHackInclude" \
    #  LDFLAGS=$MY_STD_LDFLAGS \
    #  LIBS="-lsupc++ -lstdc++" \
    #  ./configure $MY_STD_CONFIGURE_FLAGS --without-grib
  #compile
#  make  2>&1 | tee make.out
#  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END GDAL1.8.0########
