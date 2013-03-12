#!/bin/bash

#   ***************************************************************************
#     build-libs.sh - builds all needed libraries for android QGIS
#      --------------------------------------
#      Date                 : 01-Mar-2013
#      Copyright            : (C) 2013 by Marco Bernasocchi
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
QT_SRC=/home/marco/dev/android-qt

########START SCRIPT########
cd $QT_SRC
echo "BUILDING QT LIBS FOR ANDROID from $QT_SRC"

if [ "$BUILD_TYPE" == "Debug" ]; then
    BUILD_WITH_DEBUG=1
  else
    BUILD_WITH_DEBUG=0
  fi
#use to just make clean
$QT_SRC/android/androidconfigbuild.sh -n $ANDROID_NDK_ROOT -c 1 -q 0 -b 0 -k 0

$QT_SRC/android/androidconfigbuild.sh \
-n $ANDROID_NDK_ROOT \
-o $ANDROID_NDK_HOST \
-f $ANDROID_NDK_TOOLCHAIN_PREFIX \
-v $ANDROID_NDK_TOOLCHAIN_VERSION \
-a $ANDROID_ABI \
-l $ANDROID_LEVEL \
-i $INSTALL_DIR \
-d $BUILD_WITH_DEBUG \
-D"-DQT_COORD_TYPE=double" \
-q 1
