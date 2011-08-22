#!/bin/bash

#   ***************************************************************************
#     setup-env.sh - prepares the build environnement for android QGIS
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

#######Load config#######
source `dirname $0`/config.conf

########START SCRIPT########
usage(){
 echo "Usage:"
 echo " setup-libs.sh 
        --removedownloads (-r)  removes the downloaded archives after unpacking
        --help (-h)
        --version (-v)
        --echo <text> (-e)      this option does noting"
}

echo "SETTING UP ANDROID QGIS ENVIRONEMENT"
echo "QGIS build dir (WILL BE EMPTIED): " $QGIS_BUILD_DIR
echo "NDK dir:                          " $ANDROID_NDK_ROOT
echo "Standalone toolchain dir:         " $ANDROID_NDK_TOOLCHAIN_ROOT
echo "Downloading src to:               " $SRC_DIR
echo "Installing to:                    " $INSTALL_DIR
if [ "$ANDROID_TARGET_ARCH" = "armeabi-v7a" ]; then
  echo "WARNING: armeabi-v7a builds usually don't work on android emulators"
else
  echo "NOTICE: if you build for a newer device (hummingbird, tegra,... processors)\
 armeabi-v7a arch would increase the performance. Set the architecture accordingly\
 in the conf file. Look as well for MY_FPU in the conf file for further tuning."
fi  
echo "PATH:"
echo $PATH
echo "CFLAGS:                           " $MY_STD_CFLAGS
echo "LDFLAGS:                          " $MY_STD_LDFLAGS
echo "You can configure all this and more in `dirname $0`/config.conf"

export REMOVE_DOWNLOADS=0

while test "$1" != "" ; do
        case $1 in
                --echo|-e)
                        echo "$2"
                        shift
                ;;
                --removedownloads|-r)
                        echo "$TMP_DIR and the downloaded packages will be deleted"
                        export REMOVE_DOWNLOADS=1
                ;;
                --help|-h)
                        usage
                        exit 0
                ;;
                --version|-v)
                        echo "setup.sh version 0.1"
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

#confirm settings
CONTINUE="n"
echo "OK? [y, n*]:"
read CONTINUE
CONTINUE=$(echo $CONTINUE | tr "[:upper:]" "[:lower:]")

if [ "$CONTINUE" != "y" ]; then
  echo "User Abort"
  exit 1
else
  
  #######QTUITOOLS#######
  #HACK temporary needed until necessitas will include qtuitools
  #check if qt-src are installed
  if [ -d $QT_SRC/tools/designer/src/lib/uilib ]; then
    ln -sfn $QT_SRC/tools/designer/src/lib/uilib $QT_INCLUDE/QtDesigner
    ln -sfn $QT_SRC/tools/designer/src/uitools $QT_INCLUDE/QtUiTools
    cp -rf $PATCH_DIR/qtuitools/QtDesigner/* $QT_INCLUDE/QtDesigner/
    cp -rf $PATCH_DIR/qtuitools/QtUiTools/* $QT_INCLUDE/QtUiTools/
  else
    echo "Please download the QT source using the package manager in Necessitas \
    Creator under help/start updater and rerun this script"
    exit 1
  fi

  ########CHECK IF rpl EXISTS################
  hash rpl 2>&- || { echo >&2 "The Program rpl is required but it's not installed. Aborting."; exit 1; }
  
  #preparing environnement
  android update project --name Qgis --path $APK_DIR
  mkdir -p $TMP_DIR
  mkdir -p $INSTALL_DIR/lib
  mkdir -p $QGIS_BUILD_DIR
  rm -rf $QGIS_BUILD_DIR/*
  cd $QGIS_DIR
  
  #check if an android branch of qgis is present
  set +e
    git checkout android
  set -e
  BRANCH="$(git branch 2>/dev/null | sed -e "/^\s/d" -e "s/^\*\s//")"
  
  if [ "$BRANCH" != "android" ]; then
    echo "Aborting, the qgis branch checkedout is not 'android', please clone or fork this repo: git://github.com/mbernasocchi/Quantum-GIS.git"
    exit 1
  else
    echo "Environement looks good, lets start"
  fi
  
  
  ########CREATE STANDALONE TOOLCHAIN########
  echo "CREATING STANDALONE TOOLCHAIN"
  $ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh --platform=$ANDROID_NDK_PLATFORM --install-dir=$ANDROID_NDK_TOOLCHAIN_ROOT

  echo "PATCHING STANDALONE TOOLCHAIN"
  cd $ANDROID_NDK_TOOLCHAIN_ROOT
  patch -p1 -i $PATCH_DIR/ndk_toolchain_uint64_t.patch


  #Get Updated config.sub
  wget -c "http://git.savannah.gnu.org/cgit/config.git/plain/config.sub" -O $TMP_DIR/config.sub
  #Get Updated guess.sub
  wget -c "http://git.savannah.gnu.org/cgit/config.git/plain/config.guess" -O $TMP_DIR/config.guess

  mkdir -p $SRC_DIR
  
  
  #######PROJ4#######
  echo "PROJ4"
  cd $SRC_DIR
  wget -c http://download.osgeo.org/proj/proj-4.7.0.tar.gz
  tar xf proj-4.7.0.tar.gz
  if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm proj-4.7.0.tar.gz; fi
  cd proj-4.7.0/
  cp -f $TMP_DIR/config.sub ./config.sub
  cp -f $TMP_DIR/config.guess ./config.guess
  #######END PROJ4#######

  #######GEOS3.2.2#######
  echo "GEOS3.2.2"
  cd $SRC_DIR
  wget -c http://download.osgeo.org/geos/geos-3.2.2.tar.bz2
  tar xjf geos-3.2.2.tar.bz2 
  if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm geos-3.2.2.tar.bz2; fi
  cd geos-3.2.2/
  cp -f $TMP_DIR/config.sub ./config.sub
  cp -f $TMP_DIR/config.guess ./config.guess
  #GET and apply patch for http://trac.osgeo.org/geos/ticket/222
  wget -c http://trac.osgeo.org/geos/raw-attachment/ticket/222/geos-3.2.0-ARM.patch -O geos-3.2.0-ARM.bug222.patch
  patch -i geos-3.2.0-ARM.bug222.patch -p0
  #######END GEOS3.2.2#######


  #######EXPAT2.0.1#######
  echo "EXPAT2.0.1"
  cd $SRC_DIR
  wget -c http://freefr.dl.sourceforge.net/project/expat/expat/2.0.1/expat-2.0.1.tar.gz
  tar xf expat-2.0.1.tar.gz
  if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm expat-2.0.1.tar.gz; fi
  cd expat-2.0.1/conftools/
  cp -f $TMP_DIR/config.sub ./config.sub
  cp -f $TMP_DIR/config.guess ./config.guess
  ######END EXPAT2.0.1#######
  
  
  #######GSL1.14#######
  echo "GSL1.14"
  cd $SRC_DIR
  wget -c http://ftp.gnu.org/gnu/gsl/gsl-1.14.tar.gz
  tar xf gsl-1.14.tar.gz
  if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm gsl-1.14.tar.gz; fi
  cd gsl-1.14/
  cp -f $TMP_DIR/config.sub ./config.sub
  cp -f $TMP_DIR/config.guess ./config.guess
  ######END EXPAT2.0.1#######


  #######GDAL#######
  echo "GDAL1.8.0"
  cd $SRC_DIR
  wget -c http://download.osgeo.org/gdal/gdal-1.8.0.tar.gz
  tar xf gdal-1.8.0.tar.gz
  if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm gdal-1.8.0.tar.gz; fi
  cd gdal-1.8.0/
  cp -f $TMP_DIR/config.sub ./config.sub
  cp -f $TMP_DIR/config.guess ./config.guess
  wget -c http://trac.osgeo.org/gdal/raw-attachment/ticket/3952/android.diff -O gdal-1.8.0-ANDROID.bug3952.patch
  patch -i gdal-1.8.0-ANDROID.bug3952.patch -p0
  ######END GDAL#######


  #######LIBICONV1.13.1#######
  echo "LIBICONV"
  cd $SRC_DIR
  wget -c http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.1.tar.gz
  tar xf libiconv-1.13.1.tar.gz
  if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm libiconv-1.13.1.tar.gz; fi
  cd libiconv-1.13.1/
  cp -f $TMP_DIR/config.sub ./build-aux/config.sub
  cp -f $TMP_DIR/config.guess ./build-aux/config.guess  
  cp -f $TMP_DIR/config.sub ./libcharset/build-aux/config.sub
  cp -f $TMP_DIR/config.guess ./libcharset/build-aux/config.guess
  #######END LIBICONV1.13.1#######
  
  
  #######SQLITE3.7.4#######
  echo "SQLITE"
  cd $SRC_DIR
  wget -c http://www.sqlite.org/sqlite-autoconf-3070400.tar.gz
  tar xf sqlite-autoconf-3070400.tar.gz
  if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm sqlite-autoconf-3070400.tar.gz; fi
  cd sqlite-autoconf-3070400/
  cp -f $TMP_DIR/config.sub ./config.sub
  cp -f $TMP_DIR/config.guess ./config.guess
  #######END SQLITE3.7.4#######
  

  #######QWT5.2.0#######
  echo "QWT"
  cd $SRC_DIR
  wget -c http://downloads.sourceforge.net/project/qwt/qwt/5.2.0/qwt-5.2.0.tar.bz2
  tar xjf qwt-5.2.0.tar.bz2
  if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm qwt-5.2.0.tar.bz2; fi
  cd qwt-5.2.0/

  #edit qwtconfig.pri
  sed -i "s|CONFIG     += QwtDesigner|#CONFIG     += QwtDesigner|" qwtconfig.pri
  sed -i "s|    INSTALLBASE    = /usr/local/qwt-5.2.0|    INSTALLBASE    = $INSTALL_DIR|" qwtconfig.pri
  #######END QWT5.2.0#######
  

  if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm -rf $TMP_DIR; fi
  exit 0
fi
