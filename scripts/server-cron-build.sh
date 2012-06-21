#!/bin/bash

#   ***************************************************************************
#     build-all.sh - builds android QGIS
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
start_time=`date +%s`
#######Load config#######
source `dirname $0`/config.conf
export QGIS_ANDROID_BUILD_ALL=1
export DOWNLOAD_DIR=/home/mbernasocchi/www/download

if [[ "$BUILD_TYPE" = "Release" && ! -n "${RELEASE_NUMBER+x}" ]]; then
    echo "script aborted, SET: BUILD_TYPE=Release RELEASE_NUMBER=value_from_installer_manifest ./server-cron-build.sh";
    exit 0;
fi 

cd $QGIS_DIR
git reset --hard HEAD
git pull

cd $ROOT_DIR
git reset --hard HEAD
git pull

rm -Rf $APK_DIR/bin/*

BUILD_TYPE=$BUILD_TYPE ANDROID_TARGET_ARCH=armeabi $SCRIPT_DIR/build-qgis.sh
BUILD_TYPE=$BUILD_TYPE ANDROID_TARGET_ARCH=armeabi-v7a $SCRIPT_DIR/build-qgis.sh
$SCRIPT_DIR/update-apk-env.sh

cd $APK_DIR
if [[ "$BUILD_TYPE" = "Release" ]]; then
    
    #remove armeabi-v7a optimized libs to generate armeabi only package
    rm -vrf $APK_DIR/libs/armeabi-v7a
    ant release
    cp -vf $APK_DIR/bin/qgis-release.apk $DOWNLOAD_DIR/qgis-$RELEASE_NUMBER-armeabi.apk
    
    #re add all necessary files
    $SCRIPT_DIR/update-apk-env.sh
    
    #remove armeabi libs to generate armeabi-v7a only package
    rm -vrf $APK_DIR/libs/armeabi
    ant release
    cp -vf $APK_DIR/bin/qgis-release.apk $DOWNLOAD_DIR/qgis-$RELEASE_NUMBER-armeabi-v7a.apk
    
else 
    DATE=`date +%Y%m%d`
    
    #remove armeabi-v7a optimized libs to generate armeabi only package
    rm -vrf $APK_DIR/libs/armeabi-v7a
    ant release
    #clear old nightly
    rm -rf $DOWNLOAD_DIR/nightly/qgis-nightly-*-armeabi.apk
    cp -vf $APK_DIR/bin/qgis-release.apk $DOWNLOAD_DIR/nightly/qgis-nightly-$DATE-armeabi.apk
    
    #re add all necessary files
    $SCRIPT_DIR/update-apk-env.sh
    
    #remove armeabi libs to generate armeabi-v7a only package
    rm -vrf $APK_DIR/libs/armeabi
    ant release
    #clear old nightly
    rm -rf $DOWNLOAD_DIR/nightly/qgis-nightly-*-armeabi.apk
    cp -vf $APK_DIR/bin/qgis-release.apk $DOWNLOAD_DIR/nightly/qgis-nightly-$DATE-armeabi-v7a.apk
fi

end_time=`date +%s`
seconds=`expr $end_time - $start_time`
minutes=$((seconds / 60))
seconds=$((seconds % 60))

SUBJECT="Android CRON build"
EMAIL="marco@bernawebdesign.ch"
EMAILMESSAGE="/tmp/emailmessage.txt"
echo "Successfully built all in $minutes minutes and $seconds seconds"> $EMAILMESSAGE
mail -s "$SUBJECT" "$EMAIL" < $EMAILMESSAGE
