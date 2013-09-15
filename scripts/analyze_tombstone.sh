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

# This script takes a tombstone file (taken from /data/tombstones/tombstone_XX)
# or reads from /data/log/dumpstate_app_native.txt.gz
# and as last resort reads from logcat

set -e

source `dirname $0`/config.conf

LOG_FILE=`mktemp`

if [ -n "$1" ];then
  echo "#######READING FORM $1"
  LOG_FILE=$1
else
  if $ADB pull /data/log/dumpstate_app_native.txt.gz /tmp; then
    echo "#######READING FORM dumpstate_app_native"
    gunzip /tmp/dumpstate_app_native.txt.gz
    LOG_FILE=/tmp/dumpstate_app_native.txt
#  elif $ADB pull /data/tombstones/tombstone_05 /tmp; then
#    LOG_FILE=/tmp/tombstone_05
  else
    echo "#######READING FORM LOGCAT"
    $ADB logcat -d > $LOG_FILE
  fi
fi
$ANDROID_NDK_ROOT/ndk-stack -sym $INSTALL_DIR -dump $LOG_FILE
#$ANDROID_STANDALONE_TOOLCHAIN/bin/arm-linux-androideabi-addr2line -f -e $INSTALL_DIR/libqgis.so 0017e8c8

