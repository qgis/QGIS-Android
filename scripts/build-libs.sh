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

echo "USING FOLLOWING TOOLCHAIN"
echo "CC:                               " `which $CC`
echo "CXX:                              " `which $CXX`
echo "LD:                               " `which $LD`
echo "AR:                               " `which $AR`
echo "RANLIB:                           " `which $RANLIB`
echo "AS:                               " `which $AS`
echo "GCC -v:                           " `$CC -v`

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
                --clean|-c)
                        echo "cleaning up"
                        $SCRIPT_DIR/clean-libs.sh
                        FORCE_CONTINUE=1
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
if [ ! -n "${QGIS_ANDROID_BUILD_ALL+x}" || $FORCE_CONTINUE != 1 ]; then
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

  mkdir -p $INSTALL_DIR/lib

  #adding GDBserver to libs
  cp -vf $GDB_SERVER $INSTALL_DIR/lib

#  #########QTUITOOLS########
#  echo "QTUITOOLS"	
#  cd $QT_SRC/tools/designer/src/uitools
#  mkdir -p build-$ANDROID_ABI
#  cd build-$ANDROID_ABI
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
  cd $SRC_DIR/$QWT_NAME/
  sed -i "s|    INSTALLBASE    =.*|    INSTALLBASE    = $INSTALL_DIR|" qwtconfig.pri
  mkdir -p build-$ANDROID_ABI
  cd build-$ANDROID_ABI
  #configure
  CFLAGS=$MY_STD_CFLAGS \
  CXXFLAGS=$MY_STD_CXXFLAGS \
  LDFLAGS=$MY_STD_LDFLAGS \
  $QMAKE ../qwt.pro
  #compile
  make -j$CORES 2>&1 | tee make.out
  sed -i "s|\$(INSTALL_ROOT)/libs/$ANDROID_ABI/|\$(INSTALL_ROOT)$INSTALL_DIR/lib/|" src/Makefile
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END QWT########


  #########EXPAT2.0.1########
  echo "EXPAT2.0.1"
  cd $SRC_DIR/$EXPAT_NAME/
  mkdir -p build-$ANDROID_ABI
  cd build-$ANDROID_ABI
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
  cd $SRC_DIR/$GSL_NAME/
  mkdir -p build-$ANDROID_ABI
  cd build-$ANDROID_ABI
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
  cd $SRC_DIR/$ICONV_NAME/
  mkdir -p build-$ANDROID_ABI
  cd build-$ANDROID_ABI
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
  
  #########freexl########
  echo "$FREEXL_NAME"
  cd $SRC_DIR/$FREEXL_NAME/
  mkdir -p build-$ANDROID_ABI
  cd build-$ANDROID_ABI
  #configure
  CFLAGS="$MY_STD_CFLAGS -I$INSTALL_DIR/include"\
  CXXFLAGS="$MY_STD_CXXFLAGS -I$INSTALL_DIR/include"\
  LDFLAGS="$MY_STD_LDFLAGS -L$INSTALL_DIR/lib" \
  ../configure $MY_STD_CONFIGURE_FLAGS
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END freexl########

  #########SQLITE########
  echo "SQLITE"
  cd $SRC_DIR/$SQLITE_NAME/
  mkdir -p build-$ANDROID_ABI
  cd build-$ANDROID_ABI
  #configure
  CFLAGS=$MY_STD_CFLAGS \
  CXXFLAGS=$MY_STD_CXXFLAGS \
  LDFLAGS=$MY_STD_LDFLAGS \
  ../configure $MY_STD_CONFIGURE_FLAGS
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END SQLITE########


  #########SPATIALINDEX########
  echo "SPATIALINDEX"
  cd $SRC_DIR/$SPATIALINDEX_NAME-$ANDROID_ABI/
  #configure
  CFLAGS="$MY_STD_CFLAGS" \
  CXXFLAGS="$MY_STD_CXXFLAGS" \
  LDFLAGS=$MY_STD_LDFLAGS \
  LIBS="-lgcc -lc -lm -lsupc++ -lstdc++" \
  ./configure $MY_STD_CONFIGURE_FLAGS
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END SPATIALINDEX########

  ##########PROJ4########
  echo "$PROJ_NAME"
  cd $SRC_DIR/$PROJ_NAME/
  mkdir -p build-$ANDROID_ABI
  cd build-$ANDROID_ABI
  #configure
  CFLAGS=$MY_STD_CFLAGS \
  CXXFLAGS=$MY_STD_CXXFLAGS \
  LDFLAGS=$MY_STD_LDFLAGS \
  ../configure $MY_STD_CONFIGURE_FLAGS
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END PROJ4########

  #########GEOS########
  echo "$GEOS_NAME"
  cd $SRC_DIR/$GEOS_NAME/
  mkdir -p build-$ANDROID_ABI
  cd build-$ANDROID_ABI
  #configure
  CFLAGS="$MY_STD_CFLAGS" \
  CXXFLAGS="$MY_STD_CXXFLAGS" \
  LDFLAGS=$MY_STD_LDFLAGS \
  ../configure $MY_STD_CONFIGURE_FLAGS
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END GEOS########
  
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

  #########GDAL########
  echo "$GDAL_NAME"
  cd $SRC_DIR/$GDAL_NAME-$ANDROID_ABI/
  #configure
  CFLAGS="$MY_STD_CFLAGS" \
  CXXFLAGS="$MY_STD_CXXFLAGS" \
  LDFLAGS=$MY_STD_LDFLAGS \
  LIBS="-lsupc++ -lstdc++" \
  ./configure $MY_STD_CONFIGURE_FLAGS --with-png=internal --with-jpeg=internal --with-sqlite3=yes --target=android
  #png, jpg, sqlite are needed for mbtiles
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  #########END GDAL########
  
#  #######openssl-android#######
#  echo "openssl-android"
#  cd $SRC_DIR/openssl-android
#  sed -i "/APP_ABI :=* /d" jni/Application.mk
#  echo "APP_ABI := $ANDROID_ABI" >> jni/Application.mk
#  $ANDROID_NDK_ROOT/ndk-build
#  echo "installing openssl"
#  cp -rfv include/openssl $INSTALL_DIR/include/openssl
#  cp -fv libs/$ANDROID_ABI/libcrypto.so $INSTALL_DIR/lib/
#  cp -fv libs/$ANDROID_ABI/libssl.so $INSTALL_DIR/lib/
  
  
  ########$PQ_NAME########
  echo "postgresql"
  cd $SRC_DIR/$PQ_NAME
  mkdir -p build-$ANDROID_ABI
  cd build-$ANDROID_ABI
  #no ssl  
  CPPFLAGS="-I$INSTALL_DIR/include" \
  CFLAGS="$MY_STD_CFLAGS" \
  CXXFLAGS="$MY_STD_CFLAGS" \
  LDFLAGS="$MY_STD_LDFLAGS" \
  $SRC_DIR/$PQ_NAME/configure $MY_STD_CONFIGURE_FLAGS --without-readline
  
#  #configure with openssl
#  CPPFLAGS="-I$INSTALL_DIR/include" \
#  CFLAGS="$MY_STD_CFLAGS -L$INSTALL_DIR/lib/ -I$INSTALL_DIR/include" \
#  CXXFLAGS="$CFLAGS" \
#  LDFLAGS="$MY_STD_LDFLAGS" \
#  LIBS="-lcrypto -lssl -lsupc++ -lstdc++" \
#  $SRC_DIR/$PQ_NAME/configure $MY_STD_CONFIGURE_FLAGS --without-readline --with-openssl
  
  make -j$CORES 2>&1 -C src/interfaces/libpq | tee make.out    
  
  #simulate of make install
  echo "installing libpq"
  cd $SRC_DIR/$PQ_NAME
  cp -fv src/include/postgres_ext.h $INSTALL_DIR/include
  cp -fv src/interfaces/libpq/libpq-fe.h $INSTALL_DIR/include
  cp -fv build-$ANDROID_ABI/src/interfaces/libpq/libpq.so $INSTALL_DIR/lib/
  ######END $PQ_NAME#######
  
  exit 0
fi
