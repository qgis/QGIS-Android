#!/bin/bash
#######Load config#######
source `dirname $0`/config.conf
set -x
HARDCODED_PATH='http://files.kde.org/necessitas/ministro/android/necessitas/qt5'
CORRECT_PATH='http://android.qgis.org/repository'

REPO_PATH=$ROOT_DIR/repository
MINISTRO_REPO_VERSION=5.101
RULES=rules.xml
OUT_PATH=$REPO_PATH/testing
OBJECTS_REPO=$MINISTRO_REPO_VERSION-$ANDROID_ABI
OBJECTS_PATH=$REPO_PATH/objects
QT_VERSION=$((0x040900))
READELF=arm-linux-androideabi-readelf

############END CONFIG########################

TMP_LIB_PATH=$REPO_PATH/tmpRepoLibs
XML_REPO_FILE=$OUT_PATH/$ANDROID_ABI/android-$ANDROID_LEVEL/libs-$MINISTRO_REPO_VERSION.xml

rm -rf $TMP_LIB_PATH
rm -rf $OBJECTS_PATH
rm -rf $OUT_PATH


mkdir -p $TMP_LIB_PATH 
cp -vr $INSTALL_DIR/lib/*.so $TMP_LIB_PATH
rm -vrf $TMP_LIB_PATH/libqgis*
rm -vrf $TMP_LIB_PATH/*provider*
rm -vrf $TMP_LIB_PATH/*plugin*

cd $REPO_PATH
./ministrorepogen $READELF $TMP_LIB_PATH $MINISTRO_REPO_VERSION $ANDROID_ABI $RULES $OUT_PATH $OBJECTS_REPO $QT_VERSION

#put libs
mkdir -p $OBJECTS_PATH
rm -fr $OBJECTS_PATH/$OBJECTS_REPO
cp -a $TMP_LIB_PATH $OBJECTS_PATH/$OBJECTS_REPO
rm -rf $TMP_LIB_PATH

sed -i "s|$HARDCODED_PATH|$CORRECT_PATH|" $XML_REPO_FILE
