#!/bin/bash

# In this configuration, the following dependent libraries are used:
#
# * zlib
# * c-ares
# * expat
# * sqlite3
# * openSSL
# * libssh2

## CONFIG ##
ARCH="armhf"
HOST="aarch64-linux-gnu"
PREFIX="/opt/aria2-aarch64"
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

./configure \
    --host=$HOST \
    --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
    --prefix=$PREFIX \
    --disable-nls \
    --without-gnutls \
    --with-openssl \
    --without-libxml2 \
    --with-libz --with-libz-prefix=${LOCAL_DIR} \
    --with-libexpat --with-libexpat-prefix=${LOCAL_DIR} \
    --with-slite3 --with-sqlite3-prefix=${LOCAL_DIR} \
    --with-libcares --with-libcares-prefix=${LOCAL_DIR} \
    #--with-ca-bundle='/etc/ssl/certs/ca-certificates.crt' \
    LDFLAGS="-L$LOCAL_DIR/lib" \
    PKG_CONFIG_PATH="$LOCAL_DIR/lib/pkgconfig" \
    ARIA2_STATIC=yes

$MAKE