expect -c '
set timeout -1   ;
spawn android update sdk -u --filter platform-tool,android-14,build-tools-20.0.0,extra-android-support;
expect {
    "Do you accept the license" { exp_send "y\r" ; exp_continue }
    eof
}
'
# Workaround for annotations.jar missing
# See
# http://stackoverflow.com/questions/24438748/fail-to-find-annotations-jar-after-updating-to-adt-23
cp /opt/android-sdk-linux/extras/android/support/annotations/android-support-annotations.jar /opt/android-sdk-linux/tools/support/annotations.jar
