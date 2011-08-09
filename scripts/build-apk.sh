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

cd $QTAPK_DIR
$QMAKE qgis.pro
make -j$CORES 2>&1 | tee make.out
make -j$CORES clean 2>&1 | tee make.out

#query libs.xml to se wich libs need to be deployed on the device
for libname in `xpath -q -e "/resources/array[@name=\"bundled_libs\"]/item/text()" $APK_DIR/res/values/libs.xml  2> /dev/null`
  do
    cp -f $INSTALL_DIR/lib/lib$libname.so $APK_DIR/libs/$ANDROID_TARGET_ARCH/.
  done

cd $APK_DIR
ant install
adb -d shell am start -n org.qgis.qgis/eu.licentia.necessitas.industrius.QtActivity

