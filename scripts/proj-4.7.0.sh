#PROJ4
wget http://download.osgeo.org/proj/proj-4.7.0.tar.gz
tar xf proj-4.7.0.tar.gz
if [ $REMOVE_DOWNLOADS -eq 1 ] ; then rm proj-4.7.0.tar.gz; fi
cd proj-4.7.0/
cp -f $TMP_DIR/config.sub ./config.sub

#SET compile flags

./configure --prefix=$INSTALL_DIR --host=arm-linux-androideabi

#COMPILE LIB
make -j$CORES 2>&1 | tee make.out

#INSTALL LIB
if [ $INSTALL_LIBS -eq 1 ]
  then make -j$CORES 2>&1 install | tee makeInstall.out
fi

exit 0
#END PROJ4
