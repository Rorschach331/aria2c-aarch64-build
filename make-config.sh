#!/bin/bash

# ==========================================================
# 统一环境配置 (需与 libs.sh 保持一致)
# ==========================================================
ARCH="aarch64"
HOST="aarch64-linux-gnu"
PREFIX="/opt/aria2-aarch64"
LOCAL_DIR="/opt/aria2-aarch64/build_libs"

TOOL_BIN_DIR="/opt/aria2-aarch64/tools/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin"
export PATH=${TOOL_BIN_DIR}:$PATH

CFLAGS="-march=armv8-a -mtune=cortex-a53"
CXXFLAGS=$CFLAGS
LDFLAGS="-L$LOCAL_DIR/lib"
CPPFLAGS="-I$LOCAL_DIR/include"

CC=$HOST-gcc
CXX=$HOST-g++

MAKE="make -j`nproc`"

# ==========================================================
# aria2 主程序配置
# ==========================================================
echo "Configuring aria2 for $HOST..."

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
    --with-sqlite3 --with-sqlite3-prefix=${LOCAL_DIR} \
    --with-libcares --with-libcares-prefix=${LOCAL_DIR} \
    LDFLAGS="$LDFLAGS" \
    PKG_CONFIG_PATH="$LOCAL_DIR/lib/pkgconfig" \
    ARIA2_STATIC=yes

echo "Building aria2..."
$MAKE
