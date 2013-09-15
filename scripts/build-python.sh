set -x
export NDK="/home/marco/dev/necessitas/android-ndk"
export SDK="/home/marco/dev/necessitas/android-sdk"
export NDKPLATFORM="$NDK/platforms/android-9/arch-arm"
export PATH="$NDK/toolchains/arm-linux-androideabi-4.6/prebuilt/linux-x86/bin/:$NDK:$SDK/tools:$PATH"

cd /home/marco/dev/android-python27-play/python-build-with-qt
bash bootstrap.sh && build_py.sh 

exit
#sed -i "s|CONFIG     += QwtDesigner|#CONFIG     += QwtDesigner|" qwtconfig.pri
replace: /home/tsheasha/GUC/Bachelors/android-python27/python-build/ /home/marco/dev/android-python27/python-build-with-qt/
replace: /opt/necessitas/android-ndk-r6b/ /home/marco/dev/necessitas/android-ndk/
replace: /opt/necessitas/ /home/marco/dev/necessitas/
replace: /home/marco/dev/necessitas/Android/Qt/480/ /home/marco/dev/necessitas/Android/Qt/482/
remove: -L/home/marco/dev/necessitas/unstable/Android/Qt/482/build-armeabi/install/lib

sed -i "s|/home/marco/dev/necessitas/android-ndk/sources/cxx-stl-4.4.3/gnu-libstdc++/|/home/marco/dev/necessitas/android-ndk/sources/cxx-stl/gnu-libstdc++/4.4.3/|"
sed -i "s|/home/marco/dev/necessitas/android-ndk/sources/cxx-stl/gnu-libstdc++/libs/armeabi/|/home/marco/dev/necessitas/android-ndk/sources/cxx-stl/gnu-libstdc++/4.4.3/libs/armeabi/|"


