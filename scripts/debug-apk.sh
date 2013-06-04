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


#info at:
#http://www.kandroid.org/online-pdk/guide/debugging_native.html
#http://stackoverflow.com/questions/10534367/how-to-get-ndk-gdb-working-on-android
#http://mhandroid.wordpress.com/2011/01/25/how-cc-debugging-works-on-android/

set -e

source `dirname $0`/config.conf
ADB=$ANDROID_SDK_ROOT/platform-tools/adb
PACKAGE=org.qgis.qgis

#$ADB kill-server
#sudo $ADB devices
adb shell run-as $PACKAGE killall $PACKAGE

echo "" > /tmp/logcat.log
#gnome-system-log /tmp/logcat.log &
#$ADB logcat -c
$ADB shell am force-stop $PACKAGE
$ADB shell pm clear $PACKAGE
$ADB shell am start -n $PACKAGE/org.kde.necessitas.origo.QgisActivity

$ADB pull /system/bin/app_process $TMP_DIR/app_process
$ADB pull /system/bin/linker $TMP_DIR/linker
$ADB pull /system/lib/libc.so $TMP_DIR/libc.so

#find the PID of the proces
echo `$ADB shell top -n 1 | grep $PACKAGE` > $TMP_DIR/pid.txt
PID=`sed 's/ .*//' $TMP_DIR/pid.txt`
rm -f $TMP_DIR/pid.txt

#$ADB forward tcp:5039 localfilesystem:/data/data/$PACKAGE/debug-pipe
#$ADB shell run-as $PACKAGE /data/data/$PACKAGE/lib/gdbserver +debug-pipe --attach $PID &
$ADB forward tcp:5039 tcp:5039
$ADB shell run-as $PACKAGE /data/data/$PACKAGE/lib/gdbserver :5039 --attach $PID &

#call the gdb client
$ANDROID_STANDALONE_TOOLCHAIN/bin/arm-linux-androideabi-gdb -x $TMP_DIR/gdb.setup

#$ADB logcat | tee /tmp/logcat.log


