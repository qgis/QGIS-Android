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
 echo " setup-env.sh 
        --removedownloads (-r)  removes the downloaded archives after unpacking
        --help (-h)
        --version (-v)
        --echo <text> (-e)      this option does noting
        --non-interactive (-n)  Will not prompt for confirmation"
}

echo "SETTING UP ANDROID QGIS ENVIRONEMENT"
echo "QGIS build dir (WILL BE EMPTIED): " $QGIS_BUILD_DIR
echo "NDK dir:                          " $ANDROID_NDK_ROOT
echo "Standalone toolchain dir:         " $ANDROID_STANDALONE_TOOLCHAIN
echo "Downloading src to:               " $SRC_DIR
echo "Installing to:                    " $INSTALL_DIR
if [ "$ANDROID_ABI" = "armeabi-v7a" ]; then
  echo "WARNING: armeabi-v7a builds usually don't work on android emulators"
else
  echo "NOTICE: if you build for a newer device (hummingbird, tegra,... processors)\
 armeabi-v7a arch would increase the performance. Set the architecture accordingly\
 in the conf file. Look as well for MY_FPU in the conf file for further tuning."
fi  
echo "PATH:"
echo $PATH
echo "CFLAGS:                           " $MY_STD_CFLAGS
echo "CXXFLAGS:                         " $MY_STD_CXXFLAGS
echo "LDFLAGS:                          " $MY_STD_LDFLAGS

echo "You can configure all this and more in `dirname $0`/config.conf"

export REMOVE_DOWNLOADS=0
NO_CONFIRMATION=0

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
                --non-interactive|-n)
                        echo "--non-interactiveset, not prompting for confirmation"
                        export NO_CONFIRMATION=1
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
if [ "$NO_CONFIRMATION" == 1 ]; then
  CONTINUE="y"
else
  echo "OK? [y, n*]:"
  read CONTINUE
fi
CONTINUE=$(echo $CONTINUE | tr "[:upper:]" "[:lower:]")

if [ "$CONTINUE" != "y" ]; then
  echo "User Abort"
  exit 1
else
#  #######QTUITOOLS#######
#  #HACK temporary needed until necessitas will include qtuitools
#  #check if qt-src are installed
#  if [ -d $QT_SRC/tools/designer/src/lib/uilib ]; then
#    ln -sfn $QT_SRC/tools/designer/src/lib/uilib $QT_INCLUDE/QtDesigner
#    ln -sfn $QT_SRC/tools/designer/src/uitools $QT_INCLUDE/QtUiTools
#    cp -rf $PATCH_DIR/qtuitools/QtDesigner/* $QT_INCLUDE/QtDesigner/
#    cp -rf $PATCH_DIR/qtuitools/QtUiTools/* $QT_INCLUDE/QtUiTools/
#  else
#    echo "Please download the QT source using the package manager in Necessitas \
#    Creator under help/start updater and rerun this script"
#    exit 1
#  fi

  ########CHECK IF ant EXISTS################
  hash ant 2>&- || { echo >&2 "ant required to create APK. Aborting."; exit 1; }
  
  ########CHECK IF cmake EXISTS################
  hash cmake 2>&- || { echo >&2 "cmake required to build QGIS. Aborting."; exit 1; }
  
  ########CHECK IF bison EXISTS################
  hash bison 2>&- || { echo >&2 "bison required to build QGIS. Aborting."; exit 1; }
  
  ########CHECK IF flex EXISTS################
  hash flex 2>&- || { echo >&2 "flex required to build QGIS. Aborting."; exit 1; }
  
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
  $ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh --platform=$ANDROID_NDK_PLATFORM --install-dir=$ANDROID_STANDALONE_TOOLCHAIN --toolchain=arm-linux-androideabi-$ANDROID_NDK_TOOLCHAIN_VERSION

#  echo "PATCHING STANDALONE TOOLCHAIN"
#  cd $ANDROID_STANDALONE_TOOLCHAIN
#  #http://comments.gmane.org/gmane.comp.handhelds.android.ndk/8732
#  patch -p1 -i $PATCH_DIR/ndk_toolchain_uint64_t.patch


  #Get Updated config.sub
  wget -c "http://git.savannah.gnu.org/cgit/config.git/plain/config.sub" -O $TMP_DIR/config.sub
  #Get Updated guess.sub
  wget -c "http://git.savannah.gnu.org/cgit/config.git/plain/config.guess" -O $TMP_DIR/config.guess
  chmod +x $TMP_DIR/config.*
  mkdir -p $SRC_DIR
  cd $SRC_DIR
  echo "Removing all build folders"
  rm -rvf expat-2.0.1 geos-3.3.5 libspatialite-amalgamation-3.0.1 python spatialindex-src-1.7.1-armeabi spatialindex-src-1.7.1-armeabi-v7a freexl-1.0.0d gsl-1.14 postgresql-9.0.4 qwt-5.2.0 libiconv-1.13.1 proj-4.7.0  gdal-trunk-armeabi gdal-trunk-armeabi-v7a 
  
  
  #######PROJ4#######
  echo "PROJ4"
  cd $SRC_DIR
  wget -c http://download.osgeo.org/proj/proj-4.7.0.tar.gz
  tar xf proj-4.7.0.tar.gz
  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm proj-4.7.0.tar.gz; fi
  cd proj-4.7.0/
  patch -p1 -i $PATCH_DIR/proj4.patch
  cp -vf $TMP_DIR/config.sub ./config.sub
  cp -vf $TMP_DIR/config.guess ./config.guess
  #######END PROJ4#######
  
  
  ########GEOS3.2.3#######
  echo "GEOS-3.3.5"
  cd $SRC_DIR
#  svn checkout http://svn.osgeo.org/geos/tags/3.2.3/  geos-3.2.3
  wget -c http://download.osgeo.org/geos/geos-3.3.5.tar.bz2
  tar xjf geos-3.3.5.tar.bz2
  cd geos-3.3.5/
  cp -vf $TMP_DIR/config.sub ./config.sub
  cp -vf $TMP_DIR/config.guess ./config.guess
  #GET and apply patch for http://trac.osgeo.org/geos/ticket/534
#  wget -c http://trac.osgeo.org/geos/raw-attachment/ticket/534/int64_crosscomp.patch
#  patch -i int64_crosscomp.patch -p1
#  #GET and apply patch for http://trac.osgeo.org/geos/ticket/222
#  wget -c http://trac.osgeo.org/geos/raw-attachment/ticket/222/geos-3.2.0-ARM.patch -O geos-3.2.0-ARM.bug222.patch
#  patch -i geos-3.2.0-ARM.bug222.patch -p0
#  ./autogen.sh
  patch -i $PATCH_DIR/geos.patch -p1
  #######END GEOS3.2.3#######

  #######EXPAT2.0.1#######
  echo "EXPAT2.0.1"
  cd $SRC_DIR
  wget -c http://freefr.dl.sourceforge.net/project/expat/expat/2.0.1/expat-2.0.1.tar.gz
  tar xf expat-2.0.1.tar.gz
  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm expat-2.0.1.tar.gz; fi
  cd expat-2.0.1/
  cp -vf $TMP_DIR/config.sub ./conftools/config.sub
  cp -vf $TMP_DIR/config.guess ./conftools/config.guess
  patch -i $PATCH_DIR/expat.patch -p1
  ######END EXPAT2.0.1#######
  
  
  #######GSL1.14#######
  echo "GSL1.14"
  cd $SRC_DIR
  wget -c http://ftp.gnu.org/gnu/gsl/gsl-1.14.tar.gz
  tar xf gsl-1.14.tar.gz
  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm gsl-1.14.tar.gz; fi
  cd gsl-1.14/
  patch -p1 -i $PATCH_DIR/gsl.patch
  cp -vf $TMP_DIR/config.sub ./config.sub
  cp -vf $TMP_DIR/config.guess ./config.guess
  ######END EXPAT2.0.1#######


#  #######GDAL#######
#  echo "GDAL1.8.0"
#  cd $SRC_DIR
#  wget -c http://download.osgeo.org/gdal/gdal-1.8.0.tar.gz
#  tar xf gdal-1.8.0.tar.gz
#  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm gdal-1.8.0.tar.gz; fi
#  cd gdal-1.8.0/
#  cp -vf $TMP_DIR/config.sub ./config.sub
#  cp -vf $TMP_DIR/config.guess ./config.guess
#  wget -c http://trac.osgeo.org/gdal/raw-attachment/ticket/3952/android.diff -O gdal-1.8.0-ANDROID.bug3952.patch
#  patch -i gdal-1.8.0-ANDROID.bug3952.patch -p0
#  patch -p1 -i $PATCH_DIR/gdal.patch
#  #GDAL does not seem to support building in subdirs
#  cp -vrf $SRC_DIR/gdal-1.8.0/ $SRC_DIR/gdal-1.8.0-armeabi/
#  mv -vf $SRC_DIR/gdal-1.8.0/ $SRC_DIR/gdal-1.8.0-armeabi-v7a/
  ######END GDAL#######

  ######GDAL#######
  echo "GDAL-trunk"
  cd $SRC_DIR
  if [ -d 'gdal-trunk' ]; then
    svn revert --recursive gdal-trunk
    svn up gdal-trunk
  else 
    svn checkout https://svn.osgeo.org/gdal/trunk/gdal gdal-trunk
  fi
  cd gdal-trunk/
  cp -vf $TMP_DIR/config.sub ./config.sub
  cp -vf $TMP_DIR/config.guess ./config.guess
  patch -i $PATCH_DIR/gdal.patch 
#  GDAL does not seem to support building in subdirs
  cp -vrf $SRC_DIR/gdal-trunk/ $SRC_DIR/gdal-trunk-armeabi/
  cp -vrf $SRC_DIR/gdal-trunk/ $SRC_DIR/gdal-trunk-armeabi-v7a/

  #######LIBICONV1.13.1#######
  echo "LIBICONV"
  cd $SRC_DIR
  wget -c http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.1.tar.gz
  tar xf libiconv-1.13.1.tar.gz
  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm libiconv-1.13.1.tar.gz; fi
  cd libiconv-1.13.1/
  patch -p1 -i $PATCH_DIR/libiconv.patch
  cp -vf $TMP_DIR/config.sub ./build-aux/config.sub
  cp -vf $TMP_DIR/config.guess ./build-aux/config.guess  
  cp -vf $TMP_DIR/config.sub ./libcharset/build-aux/config.sub
  cp -vf $TMP_DIR/config.guess ./libcharset/build-aux/config.guess
  #######END LIBICONV1.13.1#######
  
  #######FREEXL-1.0.0d#######
  echo "FREEXL"
  cd $SRC_DIR
  wget -c http://www.gaia-gis.it/gaia-sins/freexl-1.0.0d.tar.gz
  tar xf freexl-1.0.0d.tar.gz
  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm freexl-1.0.0d.tar.gz; fi
  cd freexl-1.0.0d/
  patch -p1 -i $PATCH_DIR/freexl.patch
  cp -vf $TMP_DIR/config.sub ./config.sub
  cp -vf $TMP_DIR/config.guess ./config.guess
  #######END freexl-1.0.0d#######
  
  #######SPATIALINDEX1.7.1#######
  echo "SPATIALINDEX"
  cd $SRC_DIR
  wget -c http://download.osgeo.org/libspatialindex/spatialindex-src-1.7.1.tar.gz
  tar xf spatialindex-src-1.7.1.tar.gz
  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm spatialindex-src-1.7.1.tar.gz; fi
  cd spatialindex-src-1.7.1/
  cp -vf $TMP_DIR/config.sub ./config.sub
  cp -vf $TMP_DIR/config.guess ./config.guess
  patch -p1 -i $PATCH_DIR/spatialindex.patch
  cp -vrf $SRC_DIR/spatialindex-src-1.7.1/ $SRC_DIR/spatialindex-src-1.7.1-armeabi/
  mv -vf $SRC_DIR/spatialindex-src-1.7.1/ $SRC_DIR/spatialindex-src-1.7.1-armeabi-v7a/
  #######END SPATIALINDEX1.7.1#######

  #########SPATIALITE3.0.1########
  echo "SPATIALITE"
  cd $SRC_DIR
  wget -c http://www.gaia-gis.it/gaia-sins/libspatialite-amalgamation-3.0.1.tar.gz
  tar xf libspatialite-amalgamation-3.0.1.tar.gz
  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm libspatialite-amalgamation-3.0.1.tar.gz; fi
  cd $SRC_DIR/libspatialite-amalgamation-3.0.1/
  patch -p1 -i $PATCH_DIR/spatialite.patch
  cp -vf $TMP_DIR/config.sub ./config.sub
  cp -vf $TMP_DIR/config.guess ./config.guess

#  #######SQLITE3.7.4#######
#  echo "SQLITE"
#  cd $SRC_DIR
#  wget -c http://www.sqlite.org/sqlite-autoconf-3070400.tar.gz
#  tar xf sqlite-autoconf-3070400.tar.gz
#  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm sqlite-autoconf-3070400.tar.gz; fi
#  cd sqlite-autoconf-3070400/
#  cp -vf $TMP_DIR/config.sub ./config.sub
#  cp -vf $TMP_DIR/config.guess ./config.guess
#  #######END SQLITE3.7.4#######
  
  #######QWT5.2.0#######
  echo "QWT"
  cd $SRC_DIR
#  wget -c http://downloads.sourceforge.net/project/qwt/qwt/5.2.0/qwt-5.2.0.tar.bz2
  tar xjf qwt-5.2.0.tar.bz2
  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm qwt-5.2.0.tar.bz2; fi
  cd qwt-5.2.0/

  #edit qwtconfig.pri
  sed -i "s|CONFIG     += QwtDesigner|#CONFIG     += QwtDesigner|" qwtconfig.pri
  sed -i "s|CONFIG           += QwtDll|CONFIG     += QwtDll plugin|" qwtconfig.pri
  #######END QWT5.2.0#######
  
#  #######openssl-android#######
#  #needed for postgresssql
#  echo "openssl-android"
#  cd $SRC_DIR
#  if [ -d "openssl-android" ]; then
#    cd openssl-android
#    git pull
#  else
#    git clone git://github.com/mbernasocchi/openssl-android.git
#  fi
#  
#  cd openssl-android
#  echo "APP_ABI := $ANDROID_ABI" >> jni/Application.mk
#  
  #######postgresql-9.0.4#######
  echo "postgresql-9.0.4"
  cd $SRC_DIR
  wget -c http://ftp.postgresql.org/pub/source/v9.0.4/postgresql-9.0.4.tar.bz2
  tar xjf postgresql-9.0.4.tar.bz2 
  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm postgresql-9.0.4.tar.bz2; fi
  cd postgresql-9.0.4/
  cp -vf $TMP_DIR/config.sub ./config/config.sub
  cp -vf $TMP_DIR/config.guess ./config/config.guess  
  
  patch -p1 -i $PATCH_DIR/libpq.patch
  #######END postgresql-9.0.4#######
  
  #######PYTHON#############################
  echo "python"
  cd $SRC_DIR  
  wget -c http://python-for-android.googlecode.com/files/python_r16.zip
  wget -c http://python-for-android.googlecode.com/files/python_extras_r13.zip

  unzip python_r16.zip
  unzip python_extras_r13.zip -d pythonTMP
  mv pythonTMP/python/* python/lib/python2.6/
  rm -rf pythonTMP
  
  #######APK###############################
  cd $APK_DIR
  android update project -p . -n qgis
  
  if [ "$REMOVE_DOWNLOADS" -eq 1 ] ; then rm -rf $TMP_DIR; fi
  exit 0
fi
