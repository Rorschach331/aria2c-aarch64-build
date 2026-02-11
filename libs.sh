#!/bin/bash

# 遇到错误立即停止
set -e

# ==========================================================
# 统一的版本号配置
# ==========================================================
ZLIB_VER="1.3.1"
OPENSSL_VER="3.4.0"
EXPAT_VER="2.4.8"
SQLITE_VER="3390000"
C_ARES_VER="1.34.4"
LIBSSH2_VER="1.11.1"

# ==========================================================
# 下载链接配置
# ==========================================================
# 切换 Zlib 到 GitHub Release 以提高稳定性
ZLIB_URL="https://github.com/madler/zlib/releases/download/v${ZLIB_VER}/zlib-${ZLIB_VER}.tar.gz"
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
BUILD_DIRECTORY="/tmp"

TOOL_BIN_DIR="/opt/aria2-aarch64/tools/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin"
export PATH=${TOOL_BIN_DIR}:$PATH

# 显式导出编译器
export CC=$HOST-gcc
export CXX=$HOST-g++
export AR=$HOST-ar
export RANLIB=$HOST-ranlib
export STRIP=$HOST-strip
export LD=$HOST-ld

export CFLAGS="-march=armv8-a -mtune=cortex-a53 -Os"
export CXXFLAGS="$CFLAGS"
# 确保在编译依赖库时也能找到之前安装的库
export LDFLAGS="-L$LOCAL_DIR/lib"
export CPPFLAGS="-I$LOCAL_DIR/include"
export PKG_CONFIG_PATH="$LOCAL_DIR/lib/pkgconfig"

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
mkdir -p $BUILD_DIRECTORY
cd $BUILD_DIRECTORY

echo "----------------------------------------------------"
echo "Building zlib-${ZLIB_VER}..."
echo "----------------------------------------------------"
$DOWNLOADER $ZLIB_URL
tar zxvf zlib-${ZLIB_VER}.tar.gz
cd zlib-${ZLIB_VER}/
# Zlib configure 不使用标准 autoconf，需要环境变量传递 CC
CC=$HOST-gcc ./configure --prefix=$PREFIX --static
$MAKE
make install
cd ..

echo "----------------------------------------------------"
echo "Building expat-${EXPAT_VER}..."
echo "----------------------------------------------------"
$DOWNLOADER $EXPAT_URL
tar jxvf expat-${EXPAT_VER}.tar.bz2
cd expat-${EXPAT_VER}/
./configure --host=$HOST --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
    --prefix=$PREFIX --enable-static=yes --enable-shared=no
$MAKE
make install
cd ..

echo "----------------------------------------------------"
echo "Building c-ares-${C_ARES_VER}..."
echo "----------------------------------------------------"
$DOWNLOADER $C_ARE_URL
tar zxvf c-ares-${C_ARES_VER}.tar.gz
cd c-ares-${C_ARES_VER}/
./configure --host=$HOST --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
    --prefix=$PREFIX --enable-static --disable-shared
$MAKE
make install
cd ..

echo "----------------------------------------------------"
echo "Building OpenSSL-${OPENSSL_VER}..."
echo "----------------------------------------------------"
$DOWNLOADER $OPENSSL_URL
tar zxvf openssl-${OPENSSL_VER}.tar.gz
cd openssl-${OPENSSL_VER}/
# OpenSSL 使用 Configure
# 注意：LDFLAGS 和 CPPFLAGS 在 Configure 中可能不会自动生效，需要显式传递 zlib 路径
./Configure linux-aarch64 no-shared no-module no-asm enable-legacy \
    --prefix=$PREFIX --libdir=lib \
    zlib -D_GNU_SOURCE -D_BSD_SOURCE \
    --with-zlib-lib=$LOCAL_DIR/lib \
    --with-zlib-include=$LOCAL_DIR/include \
    $CFLAGS
$MAKE
make install_sw
cd ..

echo "----------------------------------------------------"
echo "Building sqlite-autoconf-${SQLITE_VER}..."
echo "----------------------------------------------------"
$DOWNLOADER $SQLITE3_URL
tar zxvf sqlite-autoconf-${SQLITE_VER}.tar.gz
cd sqlite-autoconf-${SQLITE_VER}/
./configure --host=$HOST --prefix=$PREFIX \
    --enable-static --enable-shared \
    --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE`
$MAKE
make install
cd ..

echo "----------------------------------------------------"
echo "Building libssh2-${LIBSSH2_VER}..."
echo "----------------------------------------------------"
$DOWNLOADER $SSH2_URL
tar zxvf libssh2-${LIBSSH2_VER}.tar.gz
cd libssh2-${LIBSSH2_VER}/
# 修正 PKG_CONFIG_PATH 确保能找到 openssl
rm -rf $PREFIX/lib/pkgconfig/libssh2.pc
./configure --host=$HOST \
    --prefix=$PREFIX \
    --enable-static --disable-shared \
    --without-libgcrypt --with-openssl --without-wincng \
    --with-libssl-prefix=$PREFIX \
    LIBS="-ldl -lpthread"
$MAKE
make install
cd ..

# 清理
echo "Cleaning up..."
rm -rf c-ares* sqlite-autoconf* zlib-* expat-* openssl-* libssh2-*

# 关键修复：确保目录权限
echo "Fixing permissions..."
sudo chmod -R 755 /opt/aria2-aarch64 || true

echo "----------------------------------------------------"
echo "Verification: Checking installed libraries..."
ls -l $PREFIX/lib/
echo "----------------------------------------------------"
echo "All libraries finished!"
