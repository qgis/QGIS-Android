#GEOS3.2.2
echo "GEOS3.2.2"
wget http://download.osgeo.org/geos/geos-3.2.2.tar.bz2
tar xjf geos-3.2.2.tar.bz2 
if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm geos-3.2.2.tar.bz2; fi
cd geos-3.2.2/
cp -f $TMP_DIR/config.sub ./config.sub

#GET and apply patch for http://trac.osgeo.org/geos/ticket/222
wget http://trac.osgeo.org/geos/raw-attachment/ticket/222/geos-3.2.0-ARM.patch -O geos-3.2.0-ARM.bug222.patch
patch -i geos-3.2.0-ARM.bug222.patch -p0  

#CONFIGURE
CFLAGS="-mthumb" CXXFLAGS="-mthumb" LIBS="-lsupc++ -lstdc++" \
     ./configure --host=arm-linux-androideabi --prefix=$INSTALL_DIR

#COMPILE LIB
make -j$CORES 2>&1 | tee make.out

#INSTALL LIB
if [ $INSTALL_LIBS -eq 1 ]
  then make -j$CORES 2>&1 install | tee makeInstall.out
fi

exit 0
#GEOS3.2.2
