#GDAL
echo "GDAL"
wget http://download.osgeo.org/gdal/gdal-1.8.0.tar.gz
tar xf gdal-1.8.0.tar.gz
if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm gdal-1.8.0.tar.gz; fi
cd gdal-1.8.0/
cp -f $TMP_DIR/config.sub ./config.sub
cp -f $TMP_DIR/config.guess ./config.guess

#SET compile flags
CFLAGS="-mthumb" CXXFLAGS="-mthumb" LIBS="-lsupc++ -lstdc++" \
      ./configure --host=arm-linux-androideabi --without-grib --prefix=$INSTALL_DIR

#COMPILE LIB
make -j$CORES 2>&1 | tee make.out

#INSTALL LIB
if [ $INSTALL_LIBS -eq 1 ]
  then make -j$CORES 2>&1 install | tee makeInstall.out
fi

exit 0
#END PROJ4
