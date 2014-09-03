#!/bin/bash

# This script generates a repo to be used with ministro as client.
# it copies includes all the external QGIS dependencies and the qgis_*.so libraries
# libqgis.so



#######Load config#######
source `dirname $0`/config.conf
HARDCODED_PATH='http://files.kde.org/necessitas/ministro/android/necessitas/qt5'
CORRECT_PATH='http://www.qgis.org/downloads/android/repository'

QT_LIBS_URI=files.kde.org/necessitas/ministro/android/necessitas/objects/0.411-armeabi-v7a

REPO_PATH=$ROOT_DIR/repository
MINISTRO_REPO_VERSION=0.1
RULES=rules.xml
OUT_PATH=$REPO_PATH/testing
OBJECTS_REPO=$MINISTRO_REPO_VERSION-$ANDROID_ABI
OBJECTS_PATH=$REPO_PATH/objects
QT_VERSION=$((0x050301))
READELF=arm-linux-androideabi-readelf

############END CONFIG########################
if [ "$1" != "--force" ]; then
    if [ "$BUILD_TYPE" = "Debug" ]; then
        echo "################ERROR#############"
        echo "This should run only if we are building a Release package"
        echo "the debug packages are supposed to be big packages with all dependencies included"
        echo "To force call ./update-libs-repo.sh --force"
        exit 1
    fi
fi

TMP_LIB_PATH=$REPO_PATH/tmpRepoLibs
XML_REPO_FILE=$OUT_PATH/$ANDROID_ABI/android-$ANDROID_LEVEL/libs-$MINISTRO_REPO_VERSION.xml
XML_VERSIONS_FILE=$OUT_PATH/$ANDROID_ABI/android-$ANDROID_LEVEL/versions.xml
GNUSTL_LIB_PATH=$ANDROID_STANDALONE_TOOLCHAIN/$ANDROID_NDK_TOOLCHAIN_PREFIX/lib


rm -rf $TMP_LIB_PATH
rm -rf $OBJECTS_PATH
rm -rf $OUT_PATH


mkdir -p $TMP_LIB_PATH/lib
cp -vrs $INSTALL_DIR/lib/*.so $TMP_LIB_PATH/lib
cp -vfs $GNUSTL_LIB_PATH/libgnustl_shared.so $TMP_LIB_PATH/lib
#libqgis, providers and plugins are bundled
rm -vrf $TMP_LIB_PATH/lib/libqgis.so
rm -vrf $TMP_LIB_PATH/lib/*provider*
rm -vrf $TMP_LIB_PATH/lib/*plugin*
rm -vrf $TMP_LIB_PATH/lib/preloadable_libiconv.so


#GET QtLibs 
#wget -c -r -l1 --no-parent -A"*.so" https://$QT_LIBS_URI/lib
#wget -c -r -l1 --no-parent -A"*.jar" https://$QT_LIBS_URI/jar
#cp -rv $QT_LIBS_URI/lib/*.so $TMP_LIB_PATH/lib-qt
#cp -rv $QT_LIBS_URI/jar/*.jar $TMP_LIB_PATH/jar


cd $REPO_PATH
./ministrorepogen $READELF $TMP_LIB_PATH $MINISTRO_REPO_VERSION $ANDROID_ABI $RULES $OUT_PATH $OBJECTS_REPO $QT_VERSION
echo "<versions latest='$MINISTRO_REPO_VERSION'></versions>" > $XML_VERSIONS_FILE

#put libs
mkdir -p $OBJECTS_PATH
rm -fr $OBJECTS_PATH/$OBJECTS_REPO
cp -a $TMP_LIB_PATH $OBJECTS_PATH/$OBJECTS_REPO
rm -rf $TMP_LIB_PATH

#replace hardcoded paths
sed -i "s|$HARDCODED_PATH|$CORRECT_PATH|" $XML_REPO_FILE

#make qwt dependent on QtCore and QtGui
sed -i 's|<lib name="qwt" \(.*\) \(level="0" />\)|<lib name="qwt" \1 level="2" >\n\t\t<depends>\n\t\t\t<lib name="QtGui"/>\n\t\t\t<lib name="QtCore"/>\n\t\t</depends>\n\t</lib>|' $XML_REPO_FILE 

