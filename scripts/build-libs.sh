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

echo "BUILDING ANDROID QGIS LIBS2"
echo "SRC location: " $SRC_DIR
echo "NDK location: " $ANDROID_NDK_ROOT
echo "Standalone toolchain location: " $ANDROID_NDK_STANDALONE_TOOLCHAIN_ROOT
echo "PATH:" $PATH
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

#ALL_FLAGS="-c -Wno-psabi -mthumb -march=armv7-a -mfloat-abi=softfp -mfpu=vfp -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-short-enums -DANDROID -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ -Wa,--noexecstack -DQT_NO_QWS_TRANSFORMED -O2 -Os -g -fomit-frame-pointer -fno-strict-aliasing -finline-limit=64 -D_REENTRANT -Wall -Wno-psabi -W -fPIC -DQT_NO_DEBUG -DQT_GUI_LIB -DQT_CORE_LIB -DQT_SHARED -I/opt/necessitas/Android/Qt/4762/armeabi-v7a/mkspecs/default -I../../qwt-5.2.0/src -I/opt/necessitas/Android/Qt/4762/armeabi-v7a/include/QtCore -I/opt/necessitas/Android/Qt/4762/armeabi-v7a/include/QtGui -I/opt/necessitas/Android/Qt/4762/armeabi-v7a/include -Imoc -I. -I/opt/necessitas/android-ndk-r5c/platforms/android-8/arch-arm/usr/include -I/opt/necessitas/android-ndk-r5c/sources/cxx-stl/gnu-libstdc++/include -I/opt/necessitas/android-ndk-r5c/sources/cxx-stl/gnu-libstdc++/libs/armeabi/include -I."

  #########QWT5.2.0########
  echo "QWT5.2.0"	
  cd qwt-5.2.0/
  #configure
  CFLAGS='-Wno-psabi -fpic -ffunction-sections -funwind-tables -stack-protector -fno-short-enums -mthumb -march=armv7-a -mfloat-abi=softfp -mfpu=vfp -DANDROID -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__' \
  LDFLAGS='-Wl,--fix-cortex-a8' \
  $QMAKE qwt.pro
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END EXPAT2.0.1########


  #########EXPAT2.0.1########
  echo "EXPAT2.0.1"
  cd expat-2.0.1/
  #configure
  CFLAGS='-mthumb -march=armv7-a -mfloat-abi=softfp' \
  LDFLAGS='-Wl,--fix-cortex-a8' \
  ./configure --prefix=$INSTALL_DIR --host=arm-linux-androideabi
  #compile
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END EXPAT2.0.1########


  #########SQLITE3.7.4########
  echo "SQLITE"
  cd sqlite-autoconf-3070400/
  #configure
  CFLAGS='-mthumb -march=armv7-a -mfloat-abi=softfp' \
  LDFLAGS='-Wl,--fix-cortex-a8' \
  ./configure --prefix=$INSTALL_DIR --host=arm-linux-androideabi
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END SQLITE3.7.4########


  ##########PROJ4########
  echo "PROJ4"
  cd proj-4.7.0/

  #configure
  CFLAGS='-mthumb -march=armv7-a -mfloat-abi=softfp' \
  LDFLAGS='-Wl,--fix-cortex-a8' \
  ./configure --prefix=$INSTALL_DIR --host=arm-linux-androideabi

  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END PROJ4########


  #########LIBICONV1.13.1########
#  echo "LIBICONV"
#  cd libiconv-1.13.1/
#  #configure
#  CFLAGS='-mthumb -march=armv7-a -mfloat-abi=softfp' \
#  LDFLAGS='-Wl,--fix-cortex-a8' \
#  ./configure --host=arm-linux-androideabi --prefix=$INSTALL_DIR
#  #compile
#  make -j$CORES 2>&1 | tee make.out
#  make -j$CORES 2>&1 install | tee makeInstall.out
#  cd $SRC_DIR
  #########END LIBICONV1.13.1########
  

  #########GEOS3.2.2########
  echo "GEOS3.2.2"
  cd geos-3.2.2/
  #configure
  CFLAGS="-mthumb -march=armv7-a -mfloat-abi=softfp" LIBS="-lsupc++ -lstdc++" \
  LDFLAGS='-Wl,--fix-cortex-a8' \
  ./configure --host=arm-linux-androideabi --prefix=$INSTALL_DIR
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END GEOS3.2.2########


  #########GDAL1.8.0########
  echo "GDAL"
  cd gdal-1.8.0/
  #configure
  CFLAGS="-mthumb -march=armv7-a -mfloat-abi=softfp" LIBS="-lsupc++ -lstdc++" \
  LDFLAGS='-Wl,--fix-cortex-a8' \
  ./configure --host=arm-linux-androideabi --without-grib --prefix=$INSTALL_DIR
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END GDAL1.8.0########
  
  exit 0
fi
