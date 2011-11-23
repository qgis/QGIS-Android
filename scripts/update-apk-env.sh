#!/bin/bash

#   ***************************************************************************
#     build-apk.sh - builds the and installs the needed libraries for android QGIS
#      --------------------------------------
#      Date                 : 01-Aug-2011
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

APK_LIBS_DIR=$APK_DIR/libs/$ANDROID_TARGET_ARCH

#copy libs to apk
mkdir -p $APK_DIR/libs/
rm -rf $APK_DIR/libs/*
cp -rf $INSTALL_DIR/lib $APK_LIBS_DIR

#copy assets to apk 
rm -rf $APK_DIR/assets
cp -rf $INSTALL_DIR/files $APK_DIR/assets
