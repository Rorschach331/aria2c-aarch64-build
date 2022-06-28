#!/bin/bash

#IMPORTANT: Require install make binutils autoconf automake autotools-dev 
#           libtool pkg-config git curl dpkg-dev autopoint libcppunit-dev 
#           libxml2-dev libgcrypt11-dev lzip wget unzip

#COMPILER AND PATH
PREFIX=/opt/aria2-i386/build_libs
C_COMPILER="gcc"
CXX_COMPILER="g++"

#CHECK TOOL FOR DOWNLOAD
 aria2c --help > /dev/null
 if [ "$?" -eq 0 ] ; then
   DOWNLOADER="aria2c --check-certificate=false -o tools-master.zip"
 else
   DOWNLOADER="wget -c --no-check-certificate"
 fi

#BUILD TOOLS FOR RASPBERRY

 mkdir -p /opt/aria2-aarch64/tools
 cd /tmp/
 $DOWNLOADER https://mirrors.tuna.tsinghua.edu.cn/armbian-releases/_toolchain/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu.tar.xz
 xz -d gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu.tar.xz
 tar -xvf gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu.tar -C /opt/aria2-aarch64/tools/
 rm  gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu.tar
