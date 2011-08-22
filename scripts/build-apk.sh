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
mkdir -p $APK_DIR/libs/$ANDROID_TARGET_ARCH
cp -rf $INSTALL_DIR/lib/* $APK_LIBS_DIR
cp -rf $INSTALL_DIR/files/* $APK_DIR/assets

rm $APK_LIBS_DIR/libgeos.so
mv $APK_LIBS_DIR/libgeos-3.2.2.so $APK_LIBS_DIR/libgeos.so

echo "REMOVING LIBS VERSIONING"
rpl -R -e libexpat.so.1 "libexpat.so\x00\x00" $APK_LIBS_DIR
rpl -R -e libgsl.so.0 "libgsl.so\x00\x00" $APK_LIBS_DIR
rpl -R -e libiconv.so.2 "libiconv.so\x00\x00" $APK_LIBS_DIR
rpl -R -e libcharset.so.1 "libcharset.so\x00\x00" $APK_LIBS_DIR
rpl -R -e libsqlite3.so.0 "libsqlite3.so\x00\x00" $APK_LIBS_DIR
rpl -R -e libproj.so.0 "libproj.so\x00\x00" $APK_LIBS_DIR
rpl -R -e libgeos_c.so.1 "libgeos_c.so\x00\x00" $APK_LIBS_DIR
rpl -R -e libgeos-3.2.2.so "libgeos.so\x00\x00\x00\x00\x00\x00" $APK_LIBS_DIR
rpl -R -e libgdal.so.1 "libgdal.so\x00\x00" $APK_LIBS_DIR
rpl -R -e libspatialite.so.1 "libspatialite.so\x00\x00" $APK_LIBS_DIR

#remove versioned information from qgis libs 
rpl -R -e libqgis_core.so.1.8.0 "libqgis_core.so\x00\x00\x00\x00\x00\x00" $APK_LIBS_DIR
rpl -R -e libqgis_gui.so.1.8.0 "libqgis_gui.so\x00\x00\x00\x00\x00\x00" $APK_LIBS_DIR
rpl -R -e libqgis_analysis.so.1.8.0 "libqgis_analysis.so\x00\x00\x00\x00\x00\x00" $APK_LIBS_DIR
rpl -R -e libqgissqlanyconnection.so.1.8.0 "libqgissqlanyconnection.so\x00\x00\x00\x00\x00\x00" $APK_LIBS_DIR

##keytool -genkey -v -keystore my-release-key.keystore -alias bernawebdesignKey -keyalg RSA -keysize 2048 -validity 10000
##cd $APK_DIR
##ant release
###add all additional files aapt

##jarsigner -verbose -keystore my-release-key.keystore -signedjar bin/Qgis-signed.apk bin/Qgis-unsigned.apk bernawebdesignKey
##zipalign -v 4 bin/Qgis-signed.apk bin/Qgis.apk
##adb install bin/Qgis.apk

#cd $APK_DIR
#ant install

