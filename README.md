# aria2c-aarch64-build
编译aarch64平台的aria2c ,比如 n1.


***借鉴了<https://github.com/q3aql/aria2-static-builds>*** 


## 编译方法：
### 安装依赖
```
sudo apt  install \
          make binutils autoconf automake autotools-dev \
          libtool pkg-config git curl dpkg-dev autopoint libcppunit-dev \
          libxml2-dev  lzip wget -y
```
### 执行`tools.sh` 

### 执行`libs.sh`

### `clone`aria2c源码：
`git clone https://github.com/aria2/aria2.git`

### 配置
```
cd aria2
autoreconf -i
```
#### 执行`make-config.sh`

### 编译
`make`
编译完二进制文件在源码的src目录
文件尺寸过大的话，执行
` /opt/aria2-aarch64/tools/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-strip ./src/aria2c`
会减小体积，但是达不到官方2M的尺寸，有哪位知道怎么做的请指教，谢谢！
