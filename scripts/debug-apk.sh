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
#$ADB shell pm clear $PACKAGE
$ADB shell am start -n $PACKAGE/org.kde.necessitas.origo.QgisActivity

#$ADB pull /system/bin/ $TMP_DIR/bin/
#$ADB pull /system/lib/ $TMP_DIR/lib/
$ADB pull /system/bin/app_process $TMP_DIR/bin/app_process
$ADB pull /system/bin/linker $TMP_DIR/bin/linker

#find the PID of the proces
echo `$ADB shell top -n 1 | grep $PACKAGE` > $TMP_DIR/pid.txt
PID=`sed 's/ .*//' $TMP_DIR/pid.txt`
rm -f $TMP_DIR/pid.txt

$ADB forward tcp:5039 localfilesystem:/data/data/$PACKAGE/debug-pipe

echo
echo "#########VISUAL DEBUG with QtCreator###########"
echo "Copy the following into options> debugger> GDB:"
echo "************START COPY/PASTE*******************"
cat $TMP_DIR/gdb.setup
echo "************END COPY/PASTE*********************"
echo
echo "You can then use QtCreator to connect by going into" 
echo "Debug> start debugging> attach to remote server"
echo
echo "Choose armv7a kit"
echo "Set remote port to 5039"
echo "Set the exectutable to $TMP_DIR/bin/app_process"
echo
echo "#########CLI DEBUG with GDB###########"

read -n1 -p "Run comandline GDB? [y,n]" doit 
case $doit in  
  y|Y) 
    echo
    echo
    echo "##########to connect to remote GDB_SERVER type:"
    echo "target remote :5039"
    echo
    $ADB shell run-as $PACKAGE /data/data/$PACKAGE/lib/gdbserver +debug-pipe --attach $PID &
    $ANDROID_STANDALONE_TOOLCHAIN/bin/arm-linux-androideabi-gdb -x $TMP_DIR/gdb.setup ;; 
  *)
    echo 
    echo "Waiting for another GDB client to connect"
    echo
    $ADB shell run-as $PACKAGE /data/data/$PACKAGE/lib/gdbserver +debug-pipe --attach $PID & ;; 
esac

