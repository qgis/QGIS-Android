# QGIS for Android build

FROM phusion/baseimage
MAINTAINER Matthias Kuhn <matthias dot kuhn at gmx dot ch>

ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Install packages
RUN apt-get update
RUN apt-get install --no-install-recommends -y ant wget git cmake bison flex unzip zip expect lib32stdc++6 libc6-i386 lib32z1 openjdk-7-jdk patch make rsync

# Get / Setup Android SDK
RUN wget http://dl.google.com/android/android-sdk_r23-linux.tgz
RUN tar -xvzf android-sdk_r23-linux.tgz -C /opt

ENV PATH ${PATH}:/opt/android-sdk-linux/tools
ENV PATH ${PATH}:/opt/android-sdk-linux/platform-tools

# Build tools
#RUN echo "y" | android update sdk -u --filter platform-tools,android-14,extra-android-support,1
ADD files/install-android-sdk.sh /root/install-android-sdk.sh
RUN /root/install-android-sdk.sh
RUN rm /root/install-android-sdk.sh

# Get / Setup Android NDK
RUN wget http://dl.google.com/android/ndk/android-ndk32-r10-linux-x86_64.tar.bz2
RUN tar -xvjf android-ndk32-r10-linux-x86_64.tar.bz2 -C /opt

# Setup Qt SDK
# using a local file
# ADD files/qt5.3.1.tar.bz2 /usr/src/qt
# using a remote file
RUN mkdir -p /usr/src/qt
WORKDIR /usr/src/qt
RUN wget -c http://qgis.org/downloads/android/qt5.3.1.tar.bz2
RUN tar -jxf qt5.3.1.tar.bz2
RUN rm -f qt5.3.1.tar.bz2

# Get QGIS build scripts and source code
RUN git clone -b qt5 https://github.com/qgis/QGIS-Android.git /usr/src/QGIS-Android

# Either add QGIS source code in a volume
VOLUME ["/usr/src/QGIS"]
# Or clone it from server to container
# RUN git clone -b final-2_4_0-qt5 https://github.com/m-kuhn/QGIS.git /usr/src/QGIS

# Start building
ADD config.conf /usr/src/QGIS-Android/scripts/config.conf
ENV QGIS_ANDROID_BUILD_ALL 1

RUN git -C /usr/src/QGIS-Android pull

ENV SCRIPT_DIR /usr/src/QGIS-Android/scripts

# Manually inject python packages (Download fails too often)
# ADD files/python_27.zip /usr/src/QGIS-Android/src/python_27.zip
# ADD files/python_extras_27.zip /usr/src/QGIS-Android/src/python_extras_27.zip
#
# RUN sed -i 's@wget -c https://android-python27.googlecode.com/hg/python-build-with-qt/binaries/python_27.zip@@' $SCRIPT_DIR/setup-env.sh
# RUN sed -i 's@wget -c https://android-python27.googlecode.com/hg/python-build-with-qt/binaries/python_extras_27.zip@@' $SCRIPT_DIR/setup-env.sh

# Run build scripts
RUN $SCRIPT_DIR/setup-env.sh -n
RUN $SCRIPT_DIR/build-libs.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm android-sdk_r23-linux.tgz
RUN rm android-ndk32-r10-linux-x86_64.tar.bz2

# Install build/sync data
ADD files/package-update.sh /root/package-update.sh
ADD files/package-update-and-sync.sh /root/package-update-and-sync.sh

VOLUME ["/root/packages"]

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# For cronjobs
ADD files/crontab /etc/crontab
RUN chmod 600 /etc/crontab
RUN chown root.root  /etc/crontab
ADD ssh_config /root/.ssh/config
RUN chown root.root /root/.ssh/config
RUN chmod 600 /root/.ssh/config
ADD known_hosts /root/.ssh/known_hosts
ADD id_rsa /root/.ssh/id_rsa
RUN chmod 755 /root/packages

