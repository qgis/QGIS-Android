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

if [ -d $INSTALL_DIR/../armeabi/lib/ ]; then 
  mkdir -p $APK_DIR/libs/armeabi/
  cp -vrfs $INSTALL_DIR/../armeabi/lib/*.so $APK_DIR/libs/armeabi/
  #add gdb server if in Debug mode
  if [ "$BUILD_TYPE" == "Debug" ]; then
      cp -vrfs $GDB_SERVER $APK_DIR/libs/armeabi/
  fi
fi

if [ -d $INSTALL_DIR/../armeabi-v7a/lib/ ]; then 
  mkdir -p $APK_DIR/libs/armeabi-v7a/
  cp -vrfs $INSTALL_DIR/../armeabi-v7a/lib/*.so $APK_DIR/libs/armeabi-v7a/
  #add gdb server if in Debug mode
  if [ "$BUILD_TYPE" == "Debug" ]; then
      cp -vrfs $GDB_SERVER $APK_DIR/libs/armeabi-v7a/
  fi
fi

#create gdb.setup
echo "file $TMP_DIR/app_process" > $TMP_DIR/gdb.setup
echo "target remote :5039" >> $TMP_DIR/gdb.setup
echo "set solib-search-path $APK_DIR/libs/$ANDROID_ABI" >> $TMP_DIR/gdb.setup
INCLUDES="$ANDROID_STANDALONE_TOOLCHAIN/sysroot/usr/include $QGIS_DIR/src $SRC_DIR"
echo "directory $INCLUDES" >> $TMP_DIR/gdb.setup
echo "break QgisApp::QgisApp" >> $TMP_DIR/gdb.setup

#copy assets to apk
rm -vrf $APK_DIR/assets
cp -vrfs $INSTALL_DIR/files $APK_DIR/assets
cp -vrfs $SRC_DIR/python $APK_DIR/assets/share/
cd $APK_DIR/assets/
zip -r9 assets.zip share
rm -rf $APK_DIR/assets/share/
