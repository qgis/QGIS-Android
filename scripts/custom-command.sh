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


if [ "$ANDROID_TARGET_ARCH" = "armeabi-v7a" ]; then
    #include is needed to fix http://hub.qgis.org/issues/4202
    armV7aHackInclude="-I$ANDROID_NDK_TOOLCHAIN_ROOT/arm-linux-androideabi/include/c++/4.4.3/arm-linux-androideabi/armv7-a"
fi

##HERE THE CUSTOM COMMANDS TO BE EXECUTED IN CONTEXT
