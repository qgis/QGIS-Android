#!/bin/bash
#
set -e
#######Load config#######
source ./config.conf

########START SCRIPT########
usage(){
 echo "Usage:"
 echo " build-libs.sh 
        --help (-h)
        --version (-v)
        --echo <text> (-e)      this option does noting"
}

echo "SRC location: " $SRC_DIR
echo "NDK location: " $NDK
echo "Standalone toolchain location: " $ANDROID_NDK_TOOLCHAIN_ROOT
echo "PATH:" $PATH

export REMOVE_DOWNLOADS=0

while test "$1" != "" ; do
        case $1 in
                --echo|-e)
                        echo "$2"
                        shift
                ;;
                --help|-h)
                        usage
                        exit 0
                ;;
                --version|-v)
                        echo "build.sh version 0.0.1"
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

if [ "$CONTINUE" = "N" ]; then
  echo "Abort"
  exit 1
else
  cd $SRC_DIR

  #########PROJ4########
  echo "PROJ4"
  cd proj-4.7.0/
  #configure
  ./configure --prefix=$INSTALL_DIR --host=arm-linux-androideabi
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END PROJ4########

  #########GEOS3.2.2########
  echo "GEOS3.2.2"
  cd geos-3.2.2/
  #configure
  CFLAGS="-mthumb" CXXFLAGS="-mthumb" LIBS="-lsupc++ -lstdc++" \
       ./configure --host=arm-linux-androideabi --prefix=$INSTALL_DIR
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END GEOS3.2.2########

  #########EXPAT2.0.1########
  echo "EXPAT2.0.1"
  cd expat-2.0.1/
  #configure
  ./configure --prefix=$INSTALL_DIR --host=arm-linux-androideabi
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END EXPAT2.0.1########


  #########LIBICONV1.13.1########
  echo "LIBICONV"
  cd libiconv-1.13.1/
  #configure
  ./configure --host=arm-linux-androideabi --prefix=$INSTALL_DIR
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END LIBICONV1.13.1########
  

  #########SQLITE3.7.4########
  echo "SQLITE"
  cd sqlite-autoconf-3070400/
  #configure
  ./configure --prefix=$INSTALL_DIR --host=arm-linux-androideabi
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END SQLITE3.7.4########
  
  
  #########GDAL1.8.0########
  echo "GDAL"
  cd gdal-1.8.0/
  #configure
  CFLAGS="-mthumb" CXXFLAGS="-mthumb" LIBS="-lsupc++ -lstdc++" \
        ./configure --host=arm-linux-androideabi --without-grib --prefix=$INSTALL_DIR
  #compile
  make -j$CORES 2>&1 | tee make.out
  make -j$CORES 2>&1 install | tee makeInstall.out
  cd $SRC_DIR
  #########END GDAL1.8.0########
  

  exit 0
fi
