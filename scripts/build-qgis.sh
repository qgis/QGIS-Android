#!/bin/bash

#   ***************************************************************************
#     build-qgis.sh - builds android QGIS
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

#TODO
#fix QT_QTUITOOLS_INCLUDE_DIR=/usr/include/qt4/QtUiTools \
#check QT_COORD_TYPE=double is to fix the type def of qreal to float for arm in QtCore/qglobal.h

if [ -n "${QGIS_ANDROID_BUILD_ALL+x}" ]; then
  MY_CMAKE=cmake
else
  MY_CMAKE=ccmake
fi

$MY_CMAKE \
-DANDROID=ON \
-DARM_TARGET=$ANDROID_TARGET_ARCH \
-DBISON_EXECUTABLE=/usr/bin/bison \
-DCMAKE_BUILD_TYPE=None \
-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
-DCMAKE_TOOLCHAIN_FILE=$SCRIPT_DIR/android.toolchain.cmake \
-DEXECUTABLE_OUTPUT_PATH=$INSTALL_DIR/$ANDROID_TARGET_ARCH/bin \
-DEXPAT_INCLUDE_DIR=$INSTALL_DIR/include \
-DEXPAT_LIBRARY=$INSTALL_DIR/lib/libexpat.so \
-DFLEX_EXECUTABLE=/usr/bin/flex \
-DGDAL_CONFIG=$INSTALL_DIR/bin/gdal-config \
-DGDAL_CONFIG_PREFER_FWTOOLS_PAT=/bin_safe \
-DGDAL_CONFIG_PREFER_PATH=$INSTALL_DIR/bin \
-DGDAL_INCLUDE_DIR=$INSTALL_DIR/include/gdal \
-DGDAL_LIBRARY=$INSTALL_DIR/lib/libgdal.so \
-DGEOS_CONFIG=$INSTALL_DIR/bin/geos-config \
-DGEOS_CONFIG_PREFER_PATH=$INSTALL_DIR/bin \
-DGEOS_INCLUDE_DIR=$INSTALL_DIR/include \
-DGEOS_LIBRARY=$INSTALL_DIR/lib/libgeos_c.so \
-DGEOS_LIB_NAME_WITH_PREFIX=-lgeos_c \
-DGSL_CONFIG=$INSTALL_DIR/bin/gsl-config \
-DGSL_CONFIG_PREFER_PATH=$INSTALL_DIR/bin \
-DGSL_EXE_LINKER_FLAGS=-Wl,-rpath, \
-DGSL_INCLUDE_DIR=$INSTALL_DIR/include/gsl \
-DINCLUDE_DIRECTORIES=$INSTALL_DIR \
-DLDFLAGS='-Wl,--fix-cortex-a8' \
-DLIBRARY_OUTPUT_PATH_ROOT=$INSTALL_DIR \
-DNO_SWIG=true \
-DPEDANTIC=OFF \
-DPROJ_INCLUDE_DIR=$INSTALL_DIR/include \
-DPROJ_LIBRARY=$INSTALL_DIR/lib/libproj.so \
-DQT_MKSPECS_DIR=$QT_ROOT/mkspecs \
-DQT_QMAKE_EXECUTABLE=$QMAKE \
-DQT_COORD_TYPE='double' \
-DQT_QTUITOOLS_INCLUDE_DIR=/usr/include/qt4/QtUiTools \
-DQWT_INCLUDE_DIR=$SRC_DIR/qwt-5.2.0/src \
-DQWT_LIBRARY=$INSTALL_DIR/lib/libqwt.so \
-DSQLITE3_INCLUDE_DIR=$INSTALL_DIR/include \
-DSQLITE3_LIBRARY=$INSTALL_DIR/lib/libsqlite3.so \
-DWITH_APIDOC=OFF \
-DWITH_ASTYLE=OFF \
-DWITH_BINDINGS=OFF \
-DWITH_GLOBE=OFF \
-DWITH_GRASS=OFF \
-DWITH_INTERNAL_QWTPOLAR=ON \
-DWITH_INTERNAL_SPATIALITE=OFF \
-DWITH_MAPSERVER=OFF \
-DWITH_POSTGRESQL=OFF \
-DWITH_SPATIALITE=OFF \
-DWITH_TXT2TAGS_PDF=OFF \
.. && make -j$CORES install
