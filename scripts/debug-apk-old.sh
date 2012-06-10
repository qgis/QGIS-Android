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
ADB=$ANDROID_SDK_ROOT/platform-tools/adb
PACKAGE=org.qgis.qgis

#$ADB kill-server
#sudo $ADB devices

echo "" > /tmp/logcat.log
#gnome-system-log /tmp/logcat.log &
#$ADB logcat -c

$ADB shell am start -n $PACKAGE/org.kde.necessitas.origo.QtActivity

echo `$ADB shell top -n 1 | grep $PACKAGE` > $TMP_DIR/pid.txt
PID=`sed 's/ .*//' $TMP_DIR/pid.txt`
rm -f $TMP_DIR/pid.txt
$ADB forward tcp:5039 localfilesystem:/data/data/$PACKAGE/debug-pipe
$ADB shell run-as $PACKAGE /data/data/$PACKAGE/lib/gdbserver +debug-pipe --attach $PID


#$ADB logcat | tee /tmp/logcat.log

$ADB pull /system/bin/app_process $TMP_DIR/app_process
echo "Pulled app_process from device/emulator."
$ADB pull /system/lib/libc.so $TMP_DIR/libc.so
echo "Pulled libc.so from device/emulator."

# Now launch the appropriate gdb client with the right init commands
#
GDBCLIENT=$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-gdb
GDBSETUP_INIT=$APK_DIR/libs/$ANDROID_TARGET_ARCH/gdb.setup
GDBSETUP=$TMP_DIR/gdb.setup
#uncomment the following to debug the remote connection only
#echo "set debug remote 1" >> $GDBSETUP
echo "file `$TMP_DIR/app_process`" >> $GDBSETUP
echo "target remote :5039" >> $GDBSETUP
$GDBCLIENT -x $GDBSETUP 
