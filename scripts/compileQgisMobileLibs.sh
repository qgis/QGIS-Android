#!/bin/sh
#
set -e
#############################
#######CONFIGURE HERE########
#############################
export ROOT_DIR=$HOME/dev/qgis-mobile
export INSTALL_DIR=$HOME/apps/qgis-mobile
export SRC_DIR=$ROOT_DIR/src
export TMP_DIR=$ROOT_DIR/tmp
export SCRIPTS_DIR=$ROOT_DIR/scripts
export NDK_VERSION=r5b
export NDK=/opt/necessitas/android-ndk-$NDK_VERSION
export ARCHITECTURE=arm
export ANDROID_API=9
#############################
#######END CONFIGURE#########
#############################

########SET COMPILERS########
export SYSROOT=$NDK/platforms/android-$ANDROID_API/arch-$ARCHITECTURE
export CC="$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-gcc --sysroot=$SYSROOT"
export CXX="$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-g++ --sysroot=$SYSROOT"
#detect cpu cores
export CORES=$(cat /proc/cpuinfo | grep processor | wc -l)

#######SET FLAGS (seems not needed yet)##########
#CXXFLAGS="-nostdlib -DHAVE_ISNAN"
#CFLAGS="  -nostdlib"
#LDFLAGS="-Wl" 
 

########START SCRIPT########
usage(){
 echo "Usage:"
 echo " compileQgisMobileLibs.sh 
        --install (-i)           installs the libs to INSTALL_DIR 
        --removedownloads (-r)  removes the downloaded archives after unpacking
        --help (-h)
        --version (-v)
        --echo <text> (-e)      this option does noting"
}

echo "NDK location: " $NDK
echo "Downloading src to: " $SRC_DIR
echo "SYSROOT: " $SYSROOT

REMOVE_DOWNLOADS=0
INSTALL_LIBS=0
while test "$1" != "" ; do
        case $1 in
                --echo|-e)
                        echo "$2"
                        shift
                ;;
                --removedownloads|-r)
                        echo "$TMP_DIR and the downloaded packages will be deleted"
                        export REMOVE_DOWNLOADS=1
                ;;
                --install|-i)
                        echo "Installing libs to: " $INSTALL_DIR
                        export INSTALL_LIBS=1
                ;;
                --help|-h)
                        usage
                        exit 0
                ;;
                --version|-v)
                        echo "compileQgisMobileLibs.sh version 0.0.1"
                        exit 0
                ;;
                -*)
                        echo "Error: no such option $1"
                        usage
                        exit 1
                ;;
        esac
        shift
done

#confirm settings
CONTINUE=n
echo "OK? [y, n*]:"
read CONTINUE
CONTINUE=$(echo $CONTINUE | tr "[:lower:]" "[:upper:]")
if [ "$CONTINUE" = "Y" ]; then
  continue
else
  echo "Abort"
  exit 1
fi


mkdir -p $TMP_DIR
#Get Updated config.sub
wget "http://git.savannah.gnu.org/gitweb/?p=autoconf.git;a=blob_plain;f=build-aux/config.sub;hb=7420ce3483ec7d50de0667ec03b86be143f72c52" -O $TMP_DIR/config.sub

#Get NDK patch
#wget "https://raw.github.com/mbernasocchi/qgis-mobile/master/patches/android-ndk-r5b.patch" -O $TMP_DIR/android-ndk-r5b.patch

#cd $NDK
#patch -p0 -i $TMP_DIR/android-ndk-r5b.patch

mkdir -p $SRC_DIR
cd $SRC_DIR
#PROJ4
$SCRIPTS_DIR/proj-4.7.0.sh
#END PROJ4
cd $SRC_DIR
#GEOS3.2.2
$SCRIPTS_DIR/geos-3.2.2.sh
#END GEOS3.2.2

if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm -rf $TMP_DIR; fi
exit 0
