#!/bin/bash

#   ***************************************************************************
#     build-release-apk.sh - builds android QGIS
#      --------------------------------------
#      Date                 : 01-Oct-2013
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
export BUILD_TYPE=Release
export ANDROID_ABI=armeabi-v7a
source `dirname $0`/config.conf

set +e
VERSION=$(grep -o -P 'android:versionName="\d\.\d\.\d' AndroidManifest.xml | grep -o -P '\d\.\d\.\d')
set -e

if [ -z "$VERSION" ]; then
    echo "could not find android:versionName in AndroidManifest.xml"
    exit 1
else
    echo "Building qgis-$VERSION-armeabi-v7a.apk"
fi

#$SCRIPT_DIR/build-qgis.sh
$SCRIPT_DIR/update-apk-env.sh
$SCRIPT_DIR/update-libs-repo.sh
$SCRIPT_DIR/build-apk.sh    
cp -vf $APK_DIR/bin/qgis-release.apk $ROOT_DIR/packages/release/qgis-$VERSION-armeabi-v7a.apk
 
