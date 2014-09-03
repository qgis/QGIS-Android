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

GIT_REV=$(git -C $QGIS_DIR rev-parse HEAD)
#update apk manifest
sed "s|<meta-data android:name=\"android.app.git_rev\" android:value=\".*\"/>|<meta-data android:name=\"android.app.git_rev\" android:value=\"$GIT_REV\"/>|" $APK_DIR/AndroidManifest.xml.template > $APK_DIR/AndroidManifest.xml

cp -f $APK_DIR/libs${BUILD_TYPE}.xml $APK_DIR/res/values/libs.xml
sed -i '/python/d' $APK_DIR/res/values/libs.xml
sed -i '/<\/array><\/resources>/d' $APK_DIR/res/values/libs.xml

if [ "$WITH_BINDINGS" = TRUE ]; then
  echo "      <item>python2.7</item>
      <item>qgispython</item>" >> $APK_DIR/res/values/libs.xml
fi

#copy libs to apk
mkdir -p $APK_DIR/libs/
rm -vrf $APK_DIR/libs/*

GNUSTL_LIB_PATH=$ANDROID_STANDALONE_TOOLCHAIN/$ANDROID_NDK_TOOLCHAIN_PREFIX/lib

cp -f $QGIS_DIR/images/splash/splash.png $APK_DIR/res/drawable/logo.png

if [ -d $INSTALL_DIR/../armeabi/lib/ ]; then 
  mkdir -p $APK_DIR/libs/armeabi/
  if [ "$BUILD_TYPE" = "Debug" ]; then
    cp -vrfs $INSTALL_DIR/../armeabi/lib/*.so $APK_DIR/libs/armeabi/
    #add libpython to apk libs
#    cp -vfs $SRC_DIR/python/lib/libpython2.7.so $APK_DIR/libs/armeabi/
    #add gdb server if in Debug mode
    cp -vrfs $GDB_SERVER $APK_DIR/libs/armeabi/
    #copy libgnustl_shared.so
    cp -vfs $GNUSTL_LIB_PATH/libgnustl_shared.so $APK_DIR/libs/armeabi/
  else
    cp -vrfs $INSTALL_DIR/../armeabi/lib/libqgis.so $APK_DIR/libs/armeabi/
    cp -vrfs $INSTALL_DIR/../armeabi/lib/lib*plugin.so $APK_DIR/libs/armeabi/
    cp -vrfs $INSTALL_DIR/../armeabi/lib/lib*provider.so $APK_DIR/libs/armeabi/
  fi
fi

if [ -d $INSTALL_DIR/../armeabi-v7a/lib/ ]; then 
  mkdir -p $APK_DIR/libs/armeabi-v7a/
  if [ "$BUILD_TYPE" = "Debug" ]; then
    cp -vrfs $INSTALL_DIR/../armeabi-v7a/lib/*.so $APK_DIR/libs/armeabi-v7a/
    #add libpython to apk libs
#    cp -vfs $SRC_DIR/python/lib/libpython2.7.so $APK_DIR/libs/armeabi-v7a/
    #add gdb server if in Debug mode
    cp -vrfs $GDB_SERVER $APK_DIR/libs/armeabi-v7a/
    #copy libgnustl_shared.so
    cp -vfs $GNUSTL_LIB_PATH/armv7-a/libgnustl_shared.so $APK_DIR/libs/armeabi-v7a/
  else
    cp -vrfs $INSTALL_DIR/../armeabi-v7a/lib/libqgis.so $APK_DIR/libs/armeabi-v7a/
    cp -vrfs $INSTALL_DIR/../armeabi-v7a/lib/lib*plugin.so $APK_DIR/libs/armeabi-v7a/
    cp -vrfs $INSTALL_DIR/../armeabi-v7a/lib/lib*provider.so $APK_DIR/libs/armeabi-v7a/
  fi
fi

#create gdb.setup
rm -f $TMP_DIR/gdb.setup
#echo "set sysroot $TMP_DIR" >> $TMP_DIR/gdb.setup
echo "set solib-search-path $APK_DIR/libs/$ANDROID_ABI" >> $TMP_DIR/gdb.setup
INCLUDES="$ANDROID_STANDALONE_TOOLCHAIN/sysroot/usr/include $QGIS_DIR/src $SRC_DIR"
echo "directory $INCLUDES" >> $TMP_DIR/gdb.setup
echo "file $TMP_DIR/bin/app_process" >> $TMP_DIR/gdb.setup
echo set "breakpoint pending on" >> $TMP_DIR/gdb.setup
echo "break QgisApp::QgisApp" >> $TMP_DIR/gdb.setup
#echo "break QgsFeatureRendererV2::_getPolygon" >> $TMP_DIR/gdb.setup

#copy assets to apk
rm -vrf $APK_DIR/assets
mkdir -p $INSTALL_DIR/files
cp -vrfs $INSTALL_DIR/files $APK_DIR/assets
#cp -vrfs $SRC_DIR/python $APK_DIR/assets/share/
#if [ $WITH_BINDINGS = TRUE ]; then
#  cp -vrfs $SRC_DIR/python $APK_DIR/assets/share/
#fi
cd $APK_DIR/assets/
zip -r9 assets.zip share
rm -rf $APK_DIR/assets/share/
