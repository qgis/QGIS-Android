#!/bin/bash


#   ***************************************************************************
#     build-qwtpolar.sh - builds qwtpolar for android QGIS
#      --------------------------------------
#      Date                 : 04-Jul-2014
#      Copyright            : (C) 2014 by Matthias Kuhn
#      Email                : matthias dot kuhn at gmx.ch
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

#########QWTPOLAR########
echo "QWTPOLAR $QWTPOLAR_VERSION"
cd $SRC_DIR/$QWTPOLAR_NAME/
sed -i "s|    QWT_POLAR_INSTALL_PREFIX    =.*|    QWT_POLAR_INSTALL_PREFIX    = $INSTALL_DIR|" qwtpolarconfig.pri
sed -i "s|QWT_POLAR_CONFIG     += QwtPolarDesigner.*|#QWT_POLAR_CONFIG     += QwtPolarDesigner|" qwtpolarconfig.pri
sed -i "s|QWT_POLAR_CONFIG     += QwtPolarExamples.*|#QWT_POLAR_CONFIG     += QwtPolarExamples|" qwtpolarconfig.pri
grep -q "^INCLUDEPATH +=.*" qwtpolarconfig.pri && sed "s|^INCLUDEPATH +=.*|INCLUDEPATH += $INSTALL_DIR/include|" -i qwtpolarconfig.pri ||
    sed "$ a\INCLUDEPATH += $INSTALL_DIR/include" -i qwtpolarconfig.pri
grep -q "^LIBS +=.*" qwtpolarconfig.pri && sed "s|^LIBS +=.*|LIBS += $INSTALL_DIR/lib/libqwt.so|" -i qwtpolarconfig.pri ||
    sed "$ a\LIBS += $INSTALL_DIR/lib/libqwt.so" -i qwtpolarconfig.pri
mkdir -p build-$ANDROID_ABI
cd build-$ANDROID_ABI
# configure
CFLAGS=$MY_STD_CFLAGS \
CXXFLAGS=$MY_STD_CXXFLAGS \
LDFLAGS=$MY_STD_LDFLAGS \
QMAKEFEATURES=$SRC_DIR/$QWT_NAME \
$QMAKE ../qwtpolar.pro
# compile
make -j$CORES 2>&1 | tee make.out
make -j$CORES 2>&1 install | tee makeInstall.out
#########END QWTPOLAR########

