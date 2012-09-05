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



#  #########SPATIALITE3.0.1########
#  cd /home/marco/dev/qgis-android/src
##  wget -c http://www.gaia-gis.it/gaia-sins/libspatialite-amalgamation-3.0.1.tar.gz # http://www.gaia-gis.it/gaia-sins/libspatialite-3.0.1.tar.gz
##  tar xf libspatialite-amalgamation-3.0.1.tar.gz
##  echo "SPATIALITE"
#  cd $SRC_DIR/libspatialite-amalgamation-3.0.1/
##  cp -f $TMP_DIR/config.sub ./config.sub
##  cp -f $TMP_DIR/config.guess ./config.guess
##  mkdir -p build-$ANDROID_TARGET_ARCH
#  cd build-$ANDROID_TARGET_ARCH
#  #configure
#  CFLAGS="$MY_STD_CFLAGS -I$INSTALL_DIR/include" \
#  CXXFLAGS="$MY_STD_CXXFLAGS -I$INSTALL_DIR/include" \
#  LDFLAGS="$MY_STD_LDFLAGS -L$INSTALL_DIR/lib" \
#  ../configure $MY_STD_CONFIGURE_FLAGS 
#  #compile
#  make -j$CORES 2>&1 | tee make.out
#  make -j$CORES 2>&1 install | tee makeInstall.out
##  #########END SQLITE3.7.4########

##  #########GDAL-trunk########
#  echo "GDAL trunk"
#  cd $SRC_DIR/gdal-trunk-$ANDROID_TARGET_ARCH/
#  #configure
#  CFLAGS="$MY_STD_CFLAGS $armV7aHackInclude" \
#  CXXFLAGS="$MY_STD_CXXFLAGS $armV7aHackInclude" \
#  LDFLAGS=$MY_STD_LDFLAGS \
#  LIBS="-lgcc -lsupc++ -lstdc++" \
#  ./configure $MY_STD_CONFIGURE_FLAGS
#  #compile
#  make -j$CORES 2>&1 | tee make.out
#  make -j$CORES 2>&1 install | tee makeInstall.out
##  #########END GDAL-trunk########


 #########SPATIALINDEX1.7.1########
  echo "SPATIALINDEX"
  cd $SRC_DIR/spatialindex-src-1.7.1-$ANDROID_TARGET_ARCH/
  #configure
  CFLAGS="$MY_STD_CFLAGS" \
  CXXFLAGS="$MY_STD_CXXFLAGS" \
  LDFLAGS=$MY_STD_LDFLAGS \
  LIBS="-lgcc -lc -lm -lsupc++ -lstdc++" \
  ./configure $MY_STD_CONFIGURE_FLAGS
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END SPATIALINDEX1.7.1########
