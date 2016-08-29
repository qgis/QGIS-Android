## For the latest version of all the build scripts, please refere to https://github.com/opengisch/OSGeo4A


This information is still here for reference:

In case of problem it is usefull to have a look at the adb logcat, to get it instal the android SDK on your pc (http://developer.android.com/guide/developing/tools/logcat.html) 
an easier alternative might be free application aLogCat on the android market (https://market.android.com/details?id=org.jtb.alogcat).

QGIS android APK package:
- Install and run the QGIS installer
- The whole installation process takes around 10min, you will be downloading around 100+Mb of qgis + 25Mb of Qt libraries, so maybe doing it on a wifi is better. 
- you might be prompted to install Ministro II by BogDan Vatra via the market, this is the Qt libraries manager.
- Once ministro is installed hit the back button twice to go back to qgis or start QGIS again and you will be asked if you want to install the Qt libraries. Say yes. 
- Once ministro is done, QGIS should start.

QGIS android dev setup:
- git clone https://github.com/qgis/QGIS-Android.git or fork an clone
- Install Necessitas (http://necessitas.kde.org/necessitas/necessitas_sdk_installer.php http://files.kde.org/necessitas/installer/release/linux-online-necessitas-alpha4.1-sdk-installer )and choose at least:
    - NDK r8b (DEFAULT)
    - Qt 4.8-armeabi (DEFAULT)
    - Android api 15
- get QGIS master from https://github.com/mbernasocchi/QGIS #or if you only want upstream code git://github.com/qgis/QGIS.git either by cloning or forking and cloning)
- git checkout android-master
- copy and configure QGIS-Android/scripts/config.templ to QGIS-Android/scripts/config.conf
- run scripts/build-all.sh
    OR
    - run scripts/setup-env.sh
    - run scripts/build-libs.sh
    - run scripts/build-qgis.sh -c
    - run scripts/update-apk-env.sh
    - run scripts/build-apk.sh
    - setup the device or emulator (see http://developer.android.com/guide/developing/index.html)
    - run scripts/run-apk.sh

example copy paste code:
 GITHUBUSERNAME="myNAME"
 GITHUBPASSWORD="myPASS"
 cd dev
 #get necessitas
 wget http://files.kde.org/necessitas/installer/release/linux-online-necessitas-alpha4.1-sdk-installer
 chmod +x linux-online-necessitas-alpha4.1-sdk-installer
 ./linux-online-necessitas-alpha4.1-sdk-installer
 # see below for adding a remote instead of cloning
 #fork QGIS
 curl -u "$GITHUBUSERNAME:$GITHUBPASSWORD" -i -d '' https://api.github.com/repos/mbernasocchi/QGIS/fork
 git clone git@github.com:$GITHUBUSERNAME/QGIS.git
 cd QGIS
 git checkout android-master
 cd ..
 #fork qqis-android
 curl -u "$GITHUBUSERNAME:$GITHUBPASSWORD" -i -d '' https://api.github.com/repos/qgis/QGIS-Android/fork
 git clone git@github.com:$GITHUBUSERNAME/QGIS-Android.git
 cp QGIS-Android/scripts/config.templ QGIS-Android/scripts/config.conf
 nano QGIS-Android/scripts/config.conf #configure to your wishes
 ./QGIS-Android/scripts/build-all.sh
 ./QGIS-Android/scripts/run-apk.sh
 
adding a remote
 git remote add qgis git://github.com/qgis/QGIS.git
 git checkout -b android-master
 git pull mbernasochi android-master


Enjoy touching QGIS :), marco@bernawebdesign.ch
