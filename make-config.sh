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

# ==========================================================
# 关键修复：使用编译器全局变量强制指定包含路径和库路径
# ==========================================================
export CC="$HOST-gcc"
export CXX="$HOST-g++"
export AR="$HOST-gcc-ar"
export RANLIB="$HOST-gcc-ranlib"
export NM="$HOST-gcc-nm"
export CPATH="$LOCAL_DIR/include"
export LIBRARY_PATH="$LOCAL_DIR/lib"
export PKG_CONFIG_PATH="$LOCAL_DIR/lib/pkgconfig"

# 编译器优化参数：
# -Os: 体积优先优化
# -flto: 链接时跨模块优化 (Link Time Optimization)
# -ffunction-sections -fdata-sections: 将函数和数据放入独立段，配合 --gc-sections 清除死代码
export CFLAGS="-march=armv8-a -mtune=cortex-a53 -Os -flto -ffunction-sections -fdata-sections"
export CXXFLAGS="$CFLAGS"

# 链接器优化参数：
# -Wl,--gc-sections: 移除未使用的代码段 (死代码消除)
# -Wl,--strip-all: 移除所有符号表和调试信息 (比 strip 命令更彻底)
export LDFLAGS="-L$LOCAL_DIR/lib -flto -Wl,--gc-sections -Wl,--strip-all"

MAKE="make -j`nproc`"

# ==========================================================
# aria2 主程序配置
# ==========================================================
echo "Configuring aria2 for $HOST..."
echo "Using CPATH: $CPATH"
echo "Check OpenSSL header: $(ls -l $LOCAL_DIR/include/openssl/opensslv.h 2>/dev/null || echo 'NOT FOUND')"
# 增加 OPENSSL_CFLAGS, OPENSSL_LIBS, LIBSSH2_CFLAGS, LIBSSH2_LIBS 显式指定
# 同时导出 LIBS 确保 configure 检测时能链接基础库
export LIBS="-ldl -lpthread -lz"

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
    --with-libssh2 --with-libssh2-prefix=${LOCAL_DIR} \
    OPENSSL_CFLAGS="-I$LOCAL_DIR/include" \
    OPENSSL_LIBS="-L$LOCAL_DIR/lib -lssl -lcrypto $LIBS" \
    LIBSSH2_CFLAGS="-I$LOCAL_DIR/include" \
    LIBSSH2_LIBS="-L$LOCAL_DIR/lib -lssh2 $LIBS" \
    ARIA2_STATIC=yes

echo "Building aria2..."
$MAKE
