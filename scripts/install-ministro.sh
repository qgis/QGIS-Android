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

cd $TMP_DIR
wget -c -O MinistroConfigurationTool-1.0.apk http://downloads.sourceforge.net/project/ministro.necessitas.p/MinistroConfigurationTool-1.0.apk?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fministro.necessitas.p%2Ffiles%2FMinistroConfigurationTool-1.0.apk%2Fdownload%3Fuse_mirror%3Dkent&ts=1312857470&use_mirror=garr
wget -c -O Ministro-2.0.apk http://downloads.sourceforge.net/project/ministro.necessitas.p/Ministro-2.0.apk?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fministro.necessitas.p%2Ffiles%2F&ts=1312857514&use_mirror=heanet
adb -e install MinistroConfigurationTool-1.0.apk
adb -e install Ministro-2.0.apk 
