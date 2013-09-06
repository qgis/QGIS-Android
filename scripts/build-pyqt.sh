ROOT_DIR=~/dev/android-python27_host
INSTALL_DIR=$ROOT_DIR/output

cd $ROOT_DIR/sip-4.11.2
python configure.py --bindir $INSTALL_DIR/bin --destdir $INSTALL_DIR/lib/python2.7/site-packages --incdir $INSTALL_DIR/include/python27 --sipdir $INSTALL_DIR/share/sip 
make -j4
make install

cd $ROOT_DIR/PyQt-x11-gpl-4.8
PYTHONPATH=$INSTALL_DIR/lib/python2.7/site-packages:$PYTHONPATH python configure.py --destdir $INSTALL_DIR/lib/python2.7/site-packages --bindir $INSTALL_DIR/bin --sipdir $INSTALL_DIR/share/sip --confirm-license
make -j4
make install

#cd $ROOT_DIR/PyQtMobility-gpl-1.0.1
#PYTHONPATH=$INSTALL_DIR:$INSTALL_DIR/lib/python2.7/site-packages:$PYTHONPATH python configure.py --destdir $INSTALL_DIR --bindir $INSTALL_DIR/bin --sipdir $INSTALL_DIR/share/sip --confirm-license
#make -j4
#make install

