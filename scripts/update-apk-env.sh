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

#copy libs to apk
mkdir -p $APK_DIR/libs/
rm -vrf $APK_DIR/libs/*
mkdir -p $APK_DIR/libs/armeabi/
mkdir -p $APK_DIR/libs/armeabi-v7a/
cp -vrf $INSTALL_DIR/../armeabi/lib/*.so $APK_DIR/libs/armeabi/
cp -vrf $INSTALL_DIR/../armeabi-v7a/lib/*.so $APK_DIR/libs/armeabi-v7a/
#copy assets to apk 
rm -vrf $APK_DIR/assets
cp -vrf $INSTALL_DIR/files $APK_DIR/assets
