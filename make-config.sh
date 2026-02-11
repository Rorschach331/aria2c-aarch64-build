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

# 显式导出编译标志，确保被 configure 子进程继承
export CC="$HOST-gcc"
export CXX="$HOST-g++"
export CFLAGS="-march=armv8-a -mtune=cortex-a53"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS="-I$LOCAL_DIR/include"
export LDFLAGS="-L$LOCAL_DIR/lib"
export PKG_CONFIG_PATH="$LOCAL_DIR/lib/pkgconfig"

MAKE="make -j`nproc`"

# ==========================================================
# aria2 主程序配置
# ==========================================================
echo "Configuring aria2 for $HOST..."
echo "Using CPPFLAGS: $CPPFLAGS"
echo "Using LDFLAGS: $LDFLAGS"

# 增加 OPENSSL_CFLAGS 和 OPENSSL_LIBS 显式指定，防止 configure 找不到头文件
# 增加 --with-libcares-prefix 等显式路径
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
    OPENSSL_CFLAGS="-I$LOCAL_DIR/include" \
    OPENSSL_LIBS="-L$LOCAL_DIR/lib -lssl -lcrypto -lz -lpthread -ldl" \
    ARIA2_STATIC=yes

echo "Building aria2..."
$MAKE
