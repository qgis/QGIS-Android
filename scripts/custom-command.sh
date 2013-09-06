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



########SQLITE#######
#  echo "SQLITE"
#  cd $SRC_DIR
#  wget -c http://www.sqlite.org/2013/$SQLITE_NAME.tar.gz
#  tar xf $SQLITE_NAME.tar.gz
#  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm $SQLITE_NAME.tar.gz; fi
#  cd $SQLITE_NAME/   
#  cp -vf $TMP_DIR/config.sub ./config.sub
#  cp -vf $TMP_DIR/config.guess ./config.guess
#  #######END SQLITE#######
# 
# 
# #########SQLITE########
#  echo "SQLITE"
#  cd $SRC_DIR/$SQLITE_NAME/
#  mkdir -p build-$ANDROID_ABI
#  cd build-$ANDROID_ABI
#  #configure
#  CFLAGS=$MY_STD_CFLAGS \
#  CXXFLAGS=$MY_STD_CXXFLAGS \
#  LDFLAGS=$MY_STD_LDFLAGS \
#  ../configure $MY_STD_CONFIGURE_FLAGS
#  #compile
#  make -j$CORES 2>&1 | tee make.out
#  make -j$CORES 2>&1 install | tee makeInstall.out
#  #########END SQLITE########
 
###########SPATIALITE########
  echo "SPATIALITE"
  cd $SRC_DIR
  wget -c http://www.gaia-gis.it/gaia-sins/libspatialite-sources/$SPATIALITE_NAME.tar.gz
  tar xf $SPATIALITE_NAME.tar.gz
  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm $SPATIALITE_NAME.tar.gz; fi
  cd $SRC_DIR/$SPATIALITE_NAME/
  patch -p1 -i $PATCH_DIR/spatialite.patch
  cp -vf $TMP_DIR/config.sub ./config.sub
  cp -vf $TMP_DIR/config.guess ./config.guess
  
  #########SPATIALITE########
  echo "$SPATIALITE_NAME"
  cd $SRC_DIR/$SPATIALITE_NAME/
  mkdir -p build-$ANDROID_ABI
  cd build-$ANDROID_ABI
  #configure
  CFLAGS="-lgnustl_shared -lm $MY_STD_CFLAGS -I$INSTALL_DIR/include" \
  CXXFLAGS="$MY_STD_CXXFLAGS -I$INSTALL_DIR/include" \
  LDFLAGS="-llog $MY_STD_LDFLAGS -L$INSTALL_DIR/lib" \
  ../configure $MY_STD_CONFIGURE_FLAGS --with-geosconfig=$SRC_DIR/$GEOS_NAME/build-$ANDROID_ABI/tools/geos-config
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END SPATIALITE########
