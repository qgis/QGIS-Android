#!/bin/bash

#   ***************************************************************************
#     server-build-release.sh - builds a release package of Android QGIS
#      --------------------------------------
#      Date                 : 21-Jun-2012
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

checkReleaseNumber()
{
  if [ $NUMBER -eq $NUMBER 2> /dev/null ]
  then
    echo "Building Release" $NUMBER
    BUILD_TYPE=Release RELEASE_NUMBER=$1 `dirname $0`/server-cron-build.sh
  else
    echo "Release Number must be an integer"
    echo -n "Release number:" 
    read NUMBER
    checkReleaseNumber
  fi
}

if [ $# -ne 1 ]
then
    echo "This script expects only one parameter"
    echo -n "Release number:"
    read NUMBER
else
    NUMBER=$1
fi

checkReleaseNumber
