#!/bin/bash

#IMPORTANT: Require install make binutils autoconf automake autotools-dev 
#           libtool pkg-config git curl dpkg-dev autopoint libcppunit-dev 
#           libxml2-dev libgcrypt11-dev lzip wget unzip


#CHECK TOOL FOR DOWNLOAD
 aria2c --help > /dev/null
 if [ "$?" -eq 0 ] ; then
   DOWNLOADER="aria2c --check-certificate=false -o tools.tar.xz"
 else
   DOWNLOADER="wget -c --no-check-certificate -O tools.tar.xz"
 fi

#BUILD TOOLS FOR RASPBERRY

 mkdir -p /opt/aria2-aarch64/tools
 ls /opt/aria2-aarch64/tools
 cd /tmp/
$DOWNLOADER  https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
 xz -d tools.tar.xz
 tar -xvf tools.tar -C /opt/aria2-aarch64/tools/
 rm  tools.tar
