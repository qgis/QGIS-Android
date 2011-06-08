#PROJ4
wget http://download.osgeo.org/proj/proj-4.7.0.tar.gz
tar xf proj-4.7.0.tar.gz
if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm proj-4.7.0.tar.gz; fi
cd proj-4.7.0/
cp -f $TMP_DIR/config.sub ./config.sub

#SET compile flags
CXX=$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-g++ \
CXXFLAGS="-nostdlib -I$NDK_PLATFORM/usr/include -I$NDK/sources/cxx-stl/gnu-libstdc++/include -I$NDK/sources/cxx-stl/gnu-libstdc++/libs/armeabi/include -DHAVE_ISNAN" \
CC=$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-gcc \
CFLAGS="  -nostdlib -I$NDK_PLATFORM/usr/include -I$NDK/sources/cxx-stl/gnu-libstdc++/include -I$NDK/sources/cxx-stl/gnu-libstdc++/libs/armeabi/include" \
LDFLAGS="-L$NDK/sources/cxx-stl/gnu-libstdc++/libs/armeabi -L$NDK_PLATFORM/usr/lib --sysroot=$NDK_PLATFORM -Wl,-rpath-link=$NDK_PLATFORM/usr/lib -lc" \
./configure --prefix=$INSTALL_DIR --host=arm-linux-androideabi

#COMPILE LIB
make -j$CORES 2>&1 | tee make.out

#INSTALL LIB
if [ $INSTALL_LIBS -eq 1 ]
  then make -j$CORES 2>&1 install | tee makeInstall.out
fi

exit 0
#END PROJ4
