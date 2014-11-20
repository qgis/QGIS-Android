#!/bin/bash


#   ***************************************************************************
#     build-qscintilla.sh - builds qscintilla for android QGIS
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

#########Qscintilla########
echo "Qscintilla $QSCINTILLA_VERSION"
cd $SRC_DIR/$QSCINTILLA_NAME/
mkdir -p build-$ANDROID_ABI
cd build-$ANDROID_ABI
# configure
CFLAGS=$MY_STD_CFLAGS \
CXXFLAGS=$MY_STD_CXXFLAGS \
LDFLAGS=$MY_STD_LDFLAGS \
$QMAKE ../Qt4Qt5/qscintilla.pro
# compile
make -j$CORES 2>&1 | tee make.out
sed -i "s|\$(INSTALL_ROOT).*/lib|\$(INSTALL_ROOT)/lib/|" Makefile
sed -i "s|\$(INSTALL_ROOT).*/include|\$(INSTALL_ROOT)/include/|" Makefile
INSTALL_ROOT=$INSTALL_DIR \
make -j$CORES 2>&1 install | tee makeInstall.out
#########END Qscintilla########

