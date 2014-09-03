#!/bin/bash

/usr/src/QGIS-Android/scripts/build-qgis-and-apk.sh
cp /usr/src/QGIS-Android/apk/bin/qgis-debug.apk /root/packages/qgis-debug-$(date +%Y-%m-%d).apk
ln -sf qgis-debug-$(date +%Y-%m-%d).apk /root/packages/qgis-debug-latest.apk

