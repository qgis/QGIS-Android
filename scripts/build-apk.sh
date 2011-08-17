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

ln -sf $INSTALL_DIR/lib $APK_DIR/libs/$ANDROID_TARGET_ARCH

##query libs.xml to se wich libs need to be deployed on the device
#for libname in `xpath -q -e "/resources/array[@name=\"bundled_libs\"]/item/text()" $APK_DIR/res/values/libs.xml  2> /dev/null`
#  do
#    cpcmd="cp -f $INSTALL_DIR/lib/lib$libname.so $APK_DIR/libs/$ANDROID_TARGET_ARCH/lib$libname.so"
#    echo $cpcmd
#    $cpcmd
#  done

#keytool -genkey -v -keystore my-release-key.keystore -alias bernawebdesignKey -keyalg RSA -keysize 2048 -validity 10000
#cd $APK_DIR
#ant release
##add all additional files aapt

#jarsigner -verbose -keystore my-release-key.keystore -signedjar bin/Qgis-signed.apk bin/Qgis-unsigned.apk bernawebdesignKey
#zipalign -v 4 bin/Qgis-signed.apk bin/Qgis.apk
#adb install bin/Qgis.apk

cd $APK_DIR
ant debug
