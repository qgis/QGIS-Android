#!/bin/bash

#   ***************************************************************************
#     build-all-variants.sh - builds android QGIS using gcc 4.4.3 and 4.6
#      --------------------------------------
#      Date                 : 21-sept-2012
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


start_time=`date +%s`
#######Load config#######
SCRIPT_DIR=`dirname $0`

export QGIS_ANDROID_BUILD_ALL=1
ANDROID_NDK_TOOLCHAIN_VERSION=4.4.3 ANDROID_ABI=armeabi $SCRIPT_DIR/build-all.sh --non-interactive 2>&1 | tee $SCRIPT_DIR/../build-all-4.4.3-armeabi.log
ANDROID_NDK_TOOLCHAIN_VERSION=4.4.3 ANDROID_ABI=armeabi-v7a $SCRIPT_DIR/build-all.sh --non-interactive 2>&1 | tee $SCRIPT_DIR/../build-all-4.4.3-armeabi-v7a.log
ANDROID_NDK_TOOLCHAIN_VERSION=4.6 ANDROID_ABI=armeabi $SCRIPT_DIR/build-all.sh --non-interactive 2>&1 | tee $SCRIPT_DIR/../build-all-4.6-armeabi.log
ANDROID_NDK_TOOLCHAIN_VERSION=4.6 ANDROID_ABI=armeabi-v7a $SCRIPT_DIR/build-all.sh --non-interactive 2>&1 | tee $SCRIPT_DIR/../build-all-4.6-armeabi-v7a.log

end_time=`date +%s`
seconds=`expr $end_time - $start_time`
minutes=$((seconds / 60))
seconds=$((seconds % 60))
echo "Successfully built all in $minutes minutes and $seconds seconds"

