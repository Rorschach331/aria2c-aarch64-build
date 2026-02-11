#!/bin/bash

# ==========================================================
# 统一的版本号配置
# ==========================================================
ZLIB_VER="1.2.11"
OPENSSL_VER="3.4.0"
EXPAT_VER="2.4.8"
SQLITE_VER="3390000"
C_ARES_VER="1.34.4"
LIBSSH2_VER="1.11.1"

# ==========================================================
# 下载链接配置
# ==========================================================
ZLIB_URL="https://sourceforge.net/projects/libpng/files/zlib/${ZLIB_VER}/zlib-${ZLIB_VER}.tar.gz"
OPENSSL_URL="https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VER}/openssl-${OPENSSL_VER}.tar.gz"
EXPAT_URL="https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VER//./_}/expat-${EXPAT_VER}.tar.bz2"
SQLITE3_URL="https://sqlite.org/2022/sqlite-autoconf-${SQLITE_VER}.tar.gz"
C_ARE_URL="https://github.com/c-ares/c-ares/releases/download/v${C_ARES_VER}/c-ares-${C_ARES_VER}.tar.gz"
SSH2_URL="https://libssh2.org/download/libssh2-${LIBSSH2_VER}.tar.gz"

# ==========================================================
# 编译环境配置
# ==========================================================
ARCH="aarch64"
HOST="aarch64-linux-gnu"
PREFIX="/opt/aria2-aarch64/build_libs"
LOCAL_DIR="/opt/aria2-aarch64/build_libs"
DEST="/opt/aria2-aarch64/build_libs"
BUILD_DIRECTORY="/tmp"

TOOL_BIN_DIR="/opt/aria2-aarch64/tools/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin"
export PATH=${TOOL_BIN_DIR}:$PATH

CFLAGS="-march=armv8-a -mtune=cortex-a53"
CXXFLAGS=$CFLAGS
LDFLAGS="-L$DEST/lib"
CPPFLAGS="-I$DEST/include"

CC=$HOST-gcc
CXX=$HOST-g++
STRIP=$HOST-strip
RANLIB=$HOST-ranlib
AR=$HOST-ar
LD=$HOST-ld

MAKE="make -j`nproc`"

# ==========================================================
# 工具检查
# ==========================================================
aria2c --help > /dev/null
if [ "$?" -eq 0 ] ; then
  DOWNLOADER="aria2c --check-certificate=false"
else
  DOWNLOADER="wget -c --no-check-certificate"
fi

# ==========================================================
# 编译流程
# ==========================================================
cd $BUILD_DIRECTORY

echo "Building zlib-${ZLIB_VER}..."
$DOWNLOADER $ZLIB_URL
tar zxvf zlib-${ZLIB_VER}.tar.gz
cd zlib-${ZLIB_VER}/
PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ \
CC=$CC STRIP=$STRIP RANLIB=$RANLIB CXX=$CXX AR=$AR LD=$LD \
./configure --prefix=$PREFIX --static
$MAKE && make install
cd ..

echo "Building expat-${EXPAT_VER}..."
$DOWNLOADER $EXPAT_URL
tar jxvf expat-${EXPAT_VER}.tar.bz2
cd expat-${EXPAT_VER}/
PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ \
CC=$CC CXX=$CXX \
./configure --host=$HOST --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` --prefix=$PREFIX --enable-static=yes --enable-shared=no
$MAKE && make install
cd ..

echo "Building c-ares-${C_ARES_VER}..."
$DOWNLOADER $C_ARE_URL
tar zxvf c-ares-${C_ARES_VER}.tar.gz
cd c-ares-${C_ARES_VER}/
PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ \
CC=$CC CXX=$CXX \
./configure --host=$HOST --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` --prefix=$PREFIX --enable-static --disable-shared
$MAKE && make install
cd ..

echo "Building OpenSSL-${OPENSSL_VER}..."
$DOWNLOADER $OPENSSL_URL
tar zxvf openssl-${OPENSSL_VER}.tar.gz
cd openssl-${OPENSSL_VER}/
# 关键修复：使用 no-module 将 provider 集成进静态库，enable-legacy 开启支持
PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ \
CC=$CC CXX=$CXX \
./Configure linux-aarch64 no-shared no-module no-asm enable-legacy $CFLAGS --prefix=$PREFIX --libdir=lib zlib -D_GNU_SOURCE -D_BSD_SOURCE --with-zlib-lib=$LOCAL_DIR/lib --with-zlib-include=$LOCAL_DIR/include
$MAKE CC=$CC && make CC=$CC install
cd ..

echo "Building sqlite-autoconf-${SQLITE_VER}..."
$DOWNLOADER $SQLITE3_URL
tar zxvf sqlite-autoconf-${SQLITE_VER}.tar.gz
cd sqlite-autoconf-${SQLITE_VER}/
PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ \
CC=$CC CXX=$CXX \
./configure --host=$HOST --prefix=$PREFIX --enable-static --enable-shared --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE`
$MAKE && make install
cd ..

echo "Building libssh2-${LIBSSH2_VER}..."
$DOWNLOADER $SSH2_URL
tar zxvf libssh2-${LIBSSH2_VER}.tar.gz
cd libssh2-${LIBSSH2_VER}/
rm -rf $PREFIX/lib/pkgconfig/libssh2.pc
PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/ LD_LIBRARY_PATH=$PREFIX/lib/ \
CC=$CC CXX=$CXX AR=$AR RANLIB=$RANLIB \
./configure --host=$HOST --without-libgcrypt --with-openssl --without-wincng \
--with-libssl-prefix=$PREFIX --prefix=$PREFIX --enable-static --disable-shared \
LDFLAGS="-L$LOCAL_DIR/lib" PKG_CONFIG_PATH="$LOCAL_DIR/lib/pkgconfig" CPPFLAGS="-I$DEST/include"
$MAKE && make install
cd ..

# 清理
echo "Cleaning up..."
rm -rf c-ares* sqlite-autoconf* zlib-* expat-* openssl-* libssh2-*

echo "All libraries version ${ZLIB_VER}, ${OPENSSL_VER}, ${EXPAT_VER}, ${SQLITE_VER}, ${C_ARES_VER}, ${LIBSSH2_VER} finished!"
