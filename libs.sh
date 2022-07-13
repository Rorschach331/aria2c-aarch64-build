#!/bin/bash

# In this configuration, the following dependent libraries are compiled:
#
# * zlib
# * c-ares
# * expat
# * sqlite3
# * openSSL
# * libssh2

#CHECK TOOL FOR DOWNLOAD
 aria2c --help > /dev/null
 if [ "$?" -eq 0 ] ; then
   DOWNLOADER="aria2c --check-certificate=false"
 else
   DOWNLOADER="wget -c --no-check-certificate"
 fi

## DEPENDENCES ##
ZLIB=https://sourceforge.net/projects/libpng/files/zlib/1.2.11/zlib-1.2.11.tar.gz
OPENSSL=https://www.openssl.org/source/openssl-1.1.1q.tar.gz
EXPAT=https://github.com/libexpat/libexpat/releases/download/R_2_4_8/expat-2.4.8.tar.bz2
SQLITE3=https://sqlite.org/2022/sqlite-autoconf-3390000.tar.gz
C_ARES=https://c-ares.org/download/c-ares-1.18.1.tar.gz
SSH2=https://www.libssh2.org/download/libssh2-1.10.0.tar.gz

## CONFIG ##
ARCH="armhf"
HOST="aarch64-linux-gnu"
PREFIX="/opt/aria2-aarch64/build_libs"
LOCAL_DIR="/opt/aria2-aarch64/build_libs"

TOOL_BIN_DIR="/opt/aria2-aarch64/tools/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin"
PATH=${TOOL_BIN_DIR}:$PATH

CFLAGS="-march=armv8-a -mtune=cortex-a53"
DEST="/opt/aria2-aarch64/build_libs"
CC=$HOST-gcc
CXX=$HOST-g++
LDFLAGS="-L$DEST/lib"
CPPFLAGS="-I$DEST/include"
CXXFLAGS=$CFLAGS
MAKE="make -j`nproc`"
CONFIGURE="./configure --prefix=${LOCAL_DIR} --host=$HOST"
BUILD_DIRECTORY=/tmp/

## BUILD ##
cd $BUILD_DIRECTORY
#
 # zlib build
  $DOWNLOADER $ZLIB
  tar zxvf zlib-1.2.11.tar.gz
  cd zlib-1.2.11/
  PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ CC=$HOST-gcc STRIP=$HOST-strip RANLIB=$HOST-ranlib CXX=$HOST-g++ AR=$HOST-ar LD=$HOST-ld ./configure --prefix=$PREFIX --static
  make
  make install
#
 # expat build
  cd ..
  $DOWNLOADER $EXPAT
  tar jxvf expat-2.4.8.tar.bz2
  cd expat-2.4.8/
  PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ CC=$HOST-gcc CXX=$HOST-g++ ./configure --host=$HOST --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` --prefix=$PREFIX --enable-static=yes --enable-shared=no
  make
  make install
#
 # c-ares build
  cd ..
  $DOWNLOADER $C_ARES
  tar zxvf c-ares-1.18.1.tar.gz
  cd c-ares-1.18.1/
  PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ CC=$HOST-gcc CXX=$HOST-g++ ./configure --host=$HOST --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` --prefix=$PREFIX --enable-static --disable-shared
  make
  make install
#
 # Openssl build
  cd ..
  $DOWNLOADER $OPENSSL
  tar zxvf openssl-1.1.1q.tar.gz
  cd openssl-1.1.1q/
  PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ CC=$HOST-gcc CXX=$HOST-g++  ./Configure linux-armv4 no-asm $CFLAGS --prefix=$PREFIX shared zlib zlib-dynamic -D_GNU_SOURCE -D_BSD_SOURCE --with-zlib-lib=$LOCAL_DIR/lib --with-zlib-include=$LOCAL_DIR/include
  make CC=$CC
  make CC=$CC install INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl
#
 # sqlite3
  cd ..
  $DOWNLOADER $SQLITE3
  tar zxvf sqlite-autoconf-3390000.tar.gz
  cd sqlite-autoconf-3390000/
  PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ CC=$HOST-gcc CXX=$HOST-g++ ./configure --host=$HOST --prefix=$PREFIX --enable-static --enable-shared --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE`
  make
  make install
#
 # libssh2
  cd ..
  $DOWNLOADER $SSH2
  tar zxvf libssh2-1.10.0.tar.gz
  cd libssh2-1.10.0/
  rm -rf $PREFIX/lib/pkgconfig/libssh2.pc
  PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ CC=$HOST-gcc CXX=$HOST-g++ AR=$HOST-ar RANLIB=$HOST-ranlib ./configure --host=$HOST --without-libgcrypt --with-openssl --without-wincng  --with-libssl-prefix=$PREFIX --prefix=$PREFIX --enable-static --disable-shared LDFLAGS="-L$LOCAL_DIR/openssl/lib" PKG_CONFIG_PATH="$LOCAL_DIR/openssl/lib/pkgconfig" CPPFLAGS="-I$DEST/openssl/include"
  make
  make install
#
 #cleaning
  cd ..
  rm -rf c-ares*
  rm -rf sqlite-autoconf*
  rm -rf zlib-*
  rm -rf expat-*
  rm -rf openssl-*
  rm -rf libssh2-*
#
 echo "finished!"
