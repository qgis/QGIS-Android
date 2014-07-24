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

cd $APK_DIR

#to generate a key ecc see http://developer.android.com/guide/publishing/app-signing.html 

if [[ "$ANDROID_ABI" = "armeabi" ]]; then
    #remove v7a optimized libs
    rm -vrf $APK_DIR/libs/armeabi-v7a
fi

if [[ "$ANDROID_ABI" = "armeabi-v7a" ]]; then
    #remove non v7a optimized libs
    rm -vrf $APK_DIR/libs/armeabi
fi

android update project --name qgis --path $APK_DIR --target android-$ANDROID_LEVEL

ant `echo $BUILD_TYPE | tr '[:upper:]' '[:lower:]'`
