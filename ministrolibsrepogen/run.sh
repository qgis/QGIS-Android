#!/bin/bash
#######Load config#######
source `dirname $0`/../scripts/config.conf
which arm-linux-androideabi-readelf
exit

READELF=arm-linux-androideabi-readelf
QT_PATH=$PWD/Qt
MINISTRO_REPO_VERSION=5.101
ARCHITECTURE=$ANDROID_ABI
RULES=rules.xml
OUT_PATH=$PWD/unstable
OBJECTS_REPO=$MINISTRO_REPO_VERSION-$ARCHITECTURE
OBJECTS_PATH=$PWD/objects
QT_VERSION=$((0x040900))
./ministrorepogen $READELF $QT_PATH $MINISTRO_REPO_VERSION $ARCHITECTURE $RULES $OUT_PATH $OBJECTS_REPO $QT_VERSION
mkdir -p $OBJECTS_PATH
rm -fr $OBJECTS_PATH/$OBJECTS_REPO
cp -a $QT_PATH $OBJECTS_PATH/$OBJECTS_REPO
