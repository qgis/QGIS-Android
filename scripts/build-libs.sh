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
echo "Standalone toolchain location: " $ANDROID_NDK_TOOLCHAIN_ROOT
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


  #adding GDBserver to libs
  cp -vf $ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.4.3/prebuilt/gdbserver $INSTALL_DIR/lib

#  #########QTUITOOLS########
#  echo "QTUITOOLS"	
#  cd $QT_SRC/tools/designer/src/uitools
#  mkdir -p build-$ANDROID_TARGET_ARCH
#  cd build-$ANDROID_TARGET_ARCH
#  CFLAGS=$MY_STD_CFLAGS \
#  CXXFLAGS=$MY_STD_CXXFLAGS \
#  LDFLAGS=$MY_STD_LDFLAGS \
#  $QMAKE  ../uitools.pro 
#  make -j$CORES 2>&1 | tee make.out
#  make -j$CORES 2>&1 install | tee makeInstall.out
#  cp -pf $QT_ROOT/lib/libQtUiTools.so $INSTALL_DIR/lib
#  #########END QTUITOOLS########
  

  #########QWT5.2.0########
  echo "QWT5.2.0"	
  cd $SRC_DIR/qwt-5.2.0/
  sed -i "s|    INSTALLBASE    =.*|    INSTALLBASE    = $INSTALL_DIR|" qwtconfig.pri
  mkdir -p build-$ANDROID_TARGET_ARCH
  cd build-$ANDROID_TARGET_ARCH
  #configure
  CFLAGS=$MY_STD_CFLAGS \
  CXXFLAGS=$MY_STD_CXXFLAGS \
  LDFLAGS=$MY_STD_LDFLAGS \
  $QMAKE ../qwt.pro
  #compile
  make -j$CORES 2>&1 | tee make.out
  sed -i "s|\$(INSTALL_ROOT)/libs/$ANDROID_TARGET_ARCH/|\$(INSTALL_ROOT)$INSTALL_DIR/lib/|" src/Makefile
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END EXPAT2.0.1########


  #########EXPAT2.0.1########
  echo "EXPAT2.0.1"
  cd $SRC_DIR/expat-2.0.1/
  mkdir -p build-$ANDROID_TARGET_ARCH
  cd build-$ANDROID_TARGET_ARCH
  #configure
  CFLAGS=$MY_STD_CFLAGS \
  CXXFLAGS=$MY_STD_CXXFLAGS \
  LDFLAGS=$MY_STD_LDFLAGS \
  ../configure $MY_STD_CONFIGURE_FLAGS
  #compile
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END EXPAT2.0.1########
  
  #########GSL1.14########
  echo "GSL1.14"
  cd $SRC_DIR/gsl-1.14/
  mkdir -p build-$ANDROID_TARGET_ARCH
  cd build-$ANDROID_TARGET_ARCH
  #configure
  CFLAGS=$MY_STD_CFLAGS \
  CXXFLAGS=$MY_STD_CXXFLAGS \
  LDFLAGS=$MY_STD_LDFLAGS \
  ../configure $MY_STD_CONFIGURE_FLAGS
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  ########END GSL1.14########

  #########LIBICONV1.13.1########
  echo "LIBICONV"
  cd $SRC_DIR/libiconv-1.13.1/
  mkdir -p build-$ANDROID_TARGET_ARCH
  cd build-$ANDROID_TARGET_ARCH
  #configure
  CFLAGS=$MY_STD_CFLAGS \
  CXXFLAGS=$MY_STD_CXXFLAGS \
  LDFLAGS=$MY_STD_LDFLAGS \
  gl_cv_header_working_stdint_h=yes \
  ../configure $MY_STD_CONFIGURE_FLAGS 
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END LIBICONV1.13.1########
  
  #########freexl1.0.0b########
  echo "freexl"
  cd $SRC_DIR/freexl-1.0.0b/
  mkdir -p build-$ANDROID_TARGET_ARCH
  cd build-$ANDROID_TARGET_ARCH
  #configure
  CFLAGS="$MY_STD_CFLAGS -I$INSTALL_DIR/include"\
  CXXFLAGS="$MY_STD_CXXFLAGS -I$INSTALL_DIR/include"\
  LDFLAGS="$MY_STD_LDFLAGS -L$INSTALL_DIR/lib" \
  ../configure $MY_STD_CONFIGURE_FLAGS
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END freexl1.0.0b########

#  #########SQLITE3.7.4########
#  echo "SQLITE"
#  cd $SRC_DIR/sqlite-autoconf-3070400/
#  mkdir -p build-$ANDROID_TARGET_ARCH
#  cd build-$ANDROID_TARGET_ARCH
#  #configure
#  CFLAGS=$MY_STD_CFLAGS \
#  CXXFLAGS=$MY_STD_CXXFLAGS \
#  LDFLAGS=$MY_STD_LDFLAGS \
#  ../configure $MY_STD_CONFIGURE_FLAGS
#  #compile
#  make -j$CORES 2>&1 | tee make.out
#  make -j$CORES 2>&1 install | tee makeInstall.out
#  #########END SQLITE3.7.4########

#  #########SPATIALITE3.0.1########
#  wget -c http://www.gaia-gis.it/gaia-sins/libspatialite-3.0.1.tar.gz
#  tar xf libspatialite-3.0.1.tar.gz
#  echo "SPATIALITE"
#  cd $SRC_DIR/libspatialite-3.0.1/
#  mkdir -p build-$ANDROID_TARGET_ARCH
#  cd build-$ANDROID_TARGET_ARCH
#  #configure
#  CFLAGS=$MY_STD_CFLAGS \
#  CXXFLAGS=$MY_STD_CXXFLAGS \
#  LDFLAGS=$MY_STD_LDFLAGS \
#  ../configure $MY_STD_CONFIGURE_FLAGS
#  #compile
#  make -j$CORES 2>&1 | tee make.out
#  make -j$CORES 2>&1 install | tee makeInstall.out
#  #########END SQLITE3.7.4########

  #########SPATIALINDEX1.7.1########
  echo "SPATIALINDEX"
  cd $SRC_DIR/spatialindex-src-1.7.1-$ANDROID_TARGET_ARCH/
  #configure
  CFLAGS="$MY_STD_CFLAGS" \
  CXXFLAGS="$MY_STD_CXXFLAGS" \
  LDFLAGS=$MY_STD_LDFLAGS \
  LIBS="-lsupc++ -lstdc++" \
  ./configure $MY_STD_CONFIGURE_FLAGS
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END SPATIALINDEX1.7.1########


  ##########PROJ4########
  echo "PROJ4"
  cd $SRC_DIR/proj-4.7.0/
  mkdir -p build-$ANDROID_TARGET_ARCH
  cd build-$ANDROID_TARGET_ARCH
  #configure
  CFLAGS=$MY_STD_CFLAGS \
  CXXFLAGS=$MY_STD_CXXFLAGS \
  LDFLAGS=$MY_STD_LDFLAGS \
  ../configure $MY_STD_CONFIGURE_FLAGS
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END PROJ4########


if [ "$ANDROID_TARGET_ARCH" = "armeabi-v7a" ]; then
    #include is needed to fix http://hub.qgis.org/issues/4202
    armV7aHackInclude="-I$ANDROID_NDK_TOOLCHAIN_ROOT/arm-linux-androideabi/include/c++/4.4.3/arm-linux-androideabi/armv7-a"
fi

  #########GEOS3.2.3########
  echo "GEOS3.2.3"
  cd $SRC_DIR/geos-3.2.3/
  mkdir -p build-$ANDROID_TARGET_ARCH
  cd build-$ANDROID_TARGET_ARCH
  #configure
  CFLAGS="$MY_STD_CFLAGS $armV7aHackInclude" \
  CXXFLAGS="$MY_STD_CXXFLAGS $armV7aHackInclude" \
  LDFLAGS=$MY_STD_LDFLAGS \
  LIBS="-lsupc++ -lstdc++" \
  ../configure $MY_STD_CONFIGURE_FLAGS
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END GEOS3.2.3########


#  #########GDAL1.8.0########
#  echo "GDAL"
#  cd $SRC_DIR/gdal-1.8.0-$ANDROID_TARGET_ARCH/
#  #configure
#  CFLAGS="$MY_STD_CFLAGS $armV7aHackInclude" \
#  CXXFLAGS="$MY_STD_CXXFLAGS $armV7aHackInclude" \
#  LDFLAGS=$MY_STD_LDFLAGS \
#  LIBS="-lsupc++ -lstdc++" \
#  ./configure $MY_STD_CONFIGURE_FLAGS --without-grib
#  #compile
#  make -j$CORES 2>&1 | tee make.out
#  make -j$CORES 2>&1 install | tee makeInstall.out
#  #########END GDAL1.8.0########
  

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


#  #######openssl-android#######
#  echo "openssl-android"
#  cd $SRC_DIR/openssl-android
#  sed -i "/APP_ABI :=* /d" jni/Application.mk
#  echo "APP_ABI := $ANDROID_TARGET_ARCH" >> jni/Application.mk
#  $ANDROID_NDK_ROOT/ndk-build
#  echo "installing openssl"
#  cp -rfv include/openssl $INSTALL_DIR/include/openssl
#  cp -fv libs/$ANDROID_TARGET_ARCH/libcrypto.so $INSTALL_DIR/lib/
#  cp -fv libs/$ANDROID_TARGET_ARCH/libssl.so $INSTALL_DIR/lib/
#  
#  
  #########postgresql-9.0.4########
  echo "postgresql"
  cd $SRC_DIR/postgresql-9.0.4
  mkdir -p build-$ANDROID_TARGET_ARCH
  cd build-$ANDROID_TARGET_ARCH
  #no ssl  
  CPPFLAGS="-I$INSTALL_DIR/include" \
  CFLAGS="$MY_STD_CFLAGS" \
  CXXFLAGS="$MY_STD_CFLAGS" \
  LDFLAGS="$MY_STD_LDFLAGS" \
  LIBS="-lsupc++ -lstdc++" \
  $SRC_DIR/postgresql-9.0.4/configure $MY_STD_CONFIGURE_FLAGS --without-readline
  
  #configure with openssl
#  CPPFLAGS="-I$INSTALL_DIR/include" \
#  CFLAGS="$MY_STD_CFLAGS -L$INSTALL_DIR/lib/ -I$INSTALL_DIR/include" \
#  CXXFLAGS="$CFLAGS" \
#  LDFLAGS="$MY_STD_LDFLAGS" \
#  LIBS="-lcrypto -lssl -lsupc++ -lstdc++" \
#  $SRC_DIR/postgresql-9.0.4/configure $MY_STD_CONFIGURE_FLAGS --without-readline --with-openssl
  
  make -j$CORES 2>&1 -C src/interfaces/libpq | tee make.out    
  
  #simulate of make install
  echo "installing libpq"
  cd ../
  cp -fv src/include/postgres_ext.h $INSTALL_DIR/include
  cp -fv src/interfaces/libpq/libpq-fe.h $INSTALL_DIR/include
  cp -fv build-$ANDROID_TARGET_ARCH/src/interfaces/libpq/libpq.so $INSTALL_DIR/lib/
  #######END postgresql-9.0.4#######
#  
  exit 0
fi
