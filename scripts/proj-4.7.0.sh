#PROJ4
wget http://download.osgeo.org/proj/proj-4.7.0.tar.gz
tar xf proj-4.7.0.tar.gz
rm proj-4.7.0.tar.gz
cd proj-4.7.0/
cp -f ../tmp/config.sub ./config.sub

CXX=$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-g++ \
CXXFLAGS="-nostdlib -I$NDK_PLATFORM/usr/include -I$NDK/sources/cxx-stl/gnu-libstdc++/include -I$NDK/sources/cxx-stl/gnu-libstdc++/libs/armeabi/include -DHAVE_ISNAN" \
CC=$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-gcc \
CFLAGS="  -nostdlib -I$NDK_PLATFORM/usr/include -I$NDK/sources/cxx-stl/gnu-libstdc++/include -I$NDK/sources/cxx-stl/gnu-libstdc++/libs/armeabi/include" \
LDFLAGS="-L$NDK/sources/cxx-stl/gnu-libstdc++/libs/armeabi -L$NDK_PLATFORM/usr/lib --sysroot=$NDK_PLATFORM -Wl,-rpath-link=$NDK_PLATFORM/usr/lib -lc" \
./configure --prefix=$INSTALL_PREFIX --host=arm-linux-androideabi

make -j$CORES 2>&1 | tee make.out
#END PROJ4
