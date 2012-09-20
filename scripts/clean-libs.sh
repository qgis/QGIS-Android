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
usage(){
 echo "Usage:"
 echo " build-libs.sh 
        --help (-h)
        --version (-v)
        --echo <text> (-e)      this option does noting"
}

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

export REMOVE_DOWNLOADS=0

while test "$1" != "" ; do
        case $1 in
                --echo|-e)
                        echo "$2"
                        shift
                ;;
                --help|-h)
                        usage
                        exit 0
                ;;
                --version|-v)
                        echo "build.sh version 0.0.1"
                        exit 0
                ;;
                -*)
                        echo "Error: no such option $1"
                        usage
                        exit 1
                ;;
        esac
        shift
done

#confirm settings if not running build_all.sh
if [ ! -n "${QGIS_ANDROID_BUILD_ALL+x}" ]; then
  CONTINUE="n"
  echo "OK? [y, n*]:"
  read CONTINUE
else
  CONTINUE="y"
fi
  
CONTINUE=$(echo $CONTINUE | tr "[:upper:]" "[:lower:]")
if [ "$CONTINUE" != "y" ]; then
  echo "Abort"
  exit 1
else
  cd $SRC_DIR

  #########QWT5.2.0########
  echo "QWT5.2.0"	
  cd $SRC_DIR/qwt-5.2.0/
  cd build-$ANDROID_TARGET_ARCH
  make clean
  #########END EXPAT2.0.1########

  #########EXPAT2.0.1########
  echo "EXPAT2.0.1"
  cd $SRC_DIR/expat-2.0.1/
  cd build-$ANDROID_TARGET_ARCH
  make clean
  #########END EXPAT2.0.1########
  
  #########GSL1.14########
  echo "GSL1.14"
  cd $SRC_DIR/gsl-1.14/
  cd build-$ANDROID_TARGET_ARCH
  make clean
  ########END GSL1.14########

  #########LIBICONV1.13.1########
  echo "LIBICONV"
  cd $SRC_DIR/libiconv-1.13.1/
  cd build-$ANDROID_TARGET_ARCH
  make clean
  #########END LIBICONV1.13.1########
  
  #########freexl1.0.0d########
  echo "freexl"
  cd $SRC_DIR/freexl-1.0.0d/
  cd build-$ANDROID_TARGET_ARCH
  make clean
  #########END freexl1.0.0d########

#  #########SQLITE3.7.4########
#  echo "SQLITE"
#  cd $SRC_DIR/sqlite-autoconf-3070400/
#  cd build-$ANDROID_TARGET_ARCH
#  make clean
#  #########END SQLITE3.7.4########

  #########SPATIALINDEX1.7.1########
  echo "SPATIALINDEX"
  cd $SRC_DIR/spatialindex-src-1.7.1-$ANDROID_TARGET_ARCH/
  make clean
  #########END SPATIALINDEX1.7.1########

  ##########PROJ4########
  echo "PROJ4"
  cd $SRC_DIR/proj-4.7.0/
  cd build-$ANDROID_TARGET_ARCH
  make clean
  #########END PROJ4########

  #########GEOS3.2.5########
  echo "GEOS3.2.5"
  cd $SRC_DIR/geos-3.3.5/
  cd build-$ANDROID_TARGET_ARCH
  make clean
  #########END GEOS3.2.5########
  
  #########SPATIALITE3.0.1########
  echo "SPATIALITE"
  cd $SRC_DIR/libspatialite-amalgamation-3.0.1/
  cd build-$ANDROID_TARGET_ARCH
  make clean
  #########END SPATIALITE3.0.1########

  #########GDAL-trunk########
  echo "GDAL trunk"
  cd $SRC_DIR/gdal-trunk-$ANDROID_TARGET_ARCH/
  make clean
  #########END GDAL-trunk########

  ########postgresql-9.0.4########
  echo "postgresql"
  cd $SRC_DIR/postgresql-9.0.4
  cd build-$ANDROID_TARGET_ARCH
  make clean
  ######END postgresql-9.0.4#######
  
  exit 0
fi
