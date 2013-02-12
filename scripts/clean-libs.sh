#!/bin/bash

#   ***************************************************************************
#     build-libs.sh - builds all needed libraries for android QGIS
#      --------------------------------------
#      Date                 : 01-Jun-2011
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

########START SCRIPT########
echo "BUILDING ANDROID QGIS LIBS"
echo "SRC location: " $SRC_DIR
echo "INSTALL location: " $INSTALL_DIR
echo "NDK location: " $ANDROID_NDK_ROOT
echo "Standalone toolchain location: " $ANDROID_STANDALONE_TOOLCHAIN
echo "PATH:"
echo $PATH
echo "CFLAGS:                           " $MY_STD_CFLAGS
echo "CXXFLAGS:                         " $MY_STD_CXXFLAGS
echo "LDFLAGS:                          " $MY_STD_LDFLAGS
echo "You can configure all this and more in `dirname $0`/config.conf"

  cd $SRC_DIR

  #########QWT5.2.0########
  echo "QWT5.2.0"	
  cd $SRC_DIR/$QWT_NAME/
  cd build-$ANDROID_ABI
  make clean
  #########END EXPAT2.0.1########

  #########EXPAT2.0.1########
  echo "EXPAT2.0.1"
  cd $SRC_DIR/$EXPAT_NAME/
  cd build-$ANDROID_ABI
  make clean
  #########END EXPAT2.0.1########
  
  #########GSL1.14########
  echo "GSL1.14"
  cd $SRC_DIR/$GSL_NAME/
  cd build-$ANDROID_ABI
  make clean
  ########END GSL1.14########

  #########LIBICONV1.13.1########
  echo "LIBICONV"
  cd $SRC_DIR/$ICONV_NAME/
  cd build-$ANDROID_ABI
  make clean
  #########END LIBICONV1.13.1########
  
  #########freexl########
  echo "$FREEXL_NAME"
  cd $SRC_DIR/$FREEXL_NAME/
  cd build-$ANDROID_ABI
  make clean
  #########END freexl########

#  #########SQLITE3.7.4########
#  echo "SQLITE"
#  cd $SRC_DIR/sqlite-autoconf-3070400/
#  cd build-$ANDROID_ABI
#  make clean
#  #########END SQLITE3.7.4########

  #########SPATIALINDEX1.7.1########
  echo "SPATIALINDEX"
  cd $SRC_DIR/$SPATIALINDEX_NAME-$ANDROID_ABI/
  make clean
  #########END SPATIALINDEX1.7.1########

  ##########PROJ4########
  echo "PROJ4"
  cd $SRC_DIR/$PROJ_NAME/
  cd build-$ANDROID_ABI
  make clean
  #########END PROJ4########

  #########GEOS########
  echo "$GEOS_NAME"
  cd $SRC_DIR/$GEOS_NAME/
  cd build-$ANDROID_ABI
  make clean
  #########END GEOS########
  
  #########SPATIALITE########
  echo "SPATIALITE"
  cd $SRC_DIR/$SPATIALITE_NAME/
  cd build-$ANDROID_ABI
  make clean
  #########END SPATIALITE########

  #########GDAL########
  echo "$GDAL_NAME"
  cd $SRC_DIR/$GDAL_NAME-$ANDROID_ABI/
  make clean
  #########END GDAL########

#  #########GDAL-trunk########
#  echo "GDAL trunk"
#  cd $SRC_DIR/gdal-trunk-$ANDROID_ABI/
#  make clean
#  #########END GDAL-trunk########

  ########$PQ_NAME########
  echo "postgresql"
  cd $SRC_DIR/$PQ_NAME
  cd build-$ANDROID_ABI
  make clean
  ######END $PQ_NAME#######
  
  exit 0
