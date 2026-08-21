# libbaresip-android (video-k120)

基于 Android NDK 交叉编译 `libbaresip` 及其全部依赖，用于 Android Studio 集成。本仓库当前分支为 `video-k120`，`baresip` 与 `re` 均跟踪内部 `k120-and-update` 分支。

* `baresip`: https://git.xswitch.cn/xyt/baresip/src/branch/k120-and-update/ 分支 `k120-and-update`
* `re`: https://git.xswitch.cn/xswitch/re/src/branch/k120-and-update/ 分支 `k120-and-update`

> 上游原始项目: https://github.com/juha-h/libbaresip-android

## 1. 环境要求

* OS: Debian 13 (或 Ubuntu 22.04+)，`uname -s` 自动识别 `linux-x86_64` / `darwin-x86_64`
* Android NDK **r27c** ，版本需与 `baresip-studio/app/build.gradle.kts` 中的 `ndkVersion` 保持一致
* Android SDK (仅 `ffmpeg-android-maker` 需要 `ANDROID_SDK_HOME`)
* 依赖工具:

```bash
apt install wget cmake make libtool m4 automake pkg-config autotools-dev git zip unzip
# opus/amr/g7221 需要 autoreconf/autogen
```

## 2. 克隆本仓库

```bash
git clone git@git.xswitch.cn:xyt/libbaresip-android.git
# 或 git clone https://git.xswitch.cn/xyt/libbaresip-android.git
cd libbaresip-android
git checkout video-k120
```

## 3. 配置 Makefile

编辑 `Makefile` 顶部 `VALUES TO CONFIGURE`：

```makefile
SDK_PATH := /opt/Android
NDK_PATH = /home/chucongqing/dev/vendors/android/sdk/android-ndk-r27c
API_LEVEL := 28
ANDROID_TARGET_ARCH := arm64-v8a   # 可选 armeabi-v7a | arm64-v8a | x86_64
OUTPUT_DIR := $(CUR_DIR)/distribution.video
```

| 变量 | 说明 | 默认值 |
|---|---|---|
| `SDK_PATH` | Android SDK 根目录，供 `ffmpeg-android-maker` 使用 | `/opt/Android` |
| `NDK_PATH` | Android NDK 根目录 | `/home/chucongqing/dev/vendors/android/sdk/android-ndk-r27c` |
| `API_LEVEL` | `android-<level>`，`TOOLCHAIN` 与 `OPENSSL` 均使用 | `28` |
| `ANDROID_TARGET_ARCH` | 目标 ABI | `arm64-v8a` |
| `OUTPUT_DIR` | 所有 `.a/.so` 与头文件的安装目录 | `$(CUR_DIR)/distribution.video` |

内部会据此自动推导 `TARGET` / `CLANG_TARGET` / `OPENSSL_ARCH` / `TOOLCHAIN` / `SYSROOT` / `CMAKE_TOOLCHAIN_FILE` 等。

常用模块开关在 `Makefile` 中亦可调整：

```makefile
MODULES := "menu;auresamp;fakevideo;augain;aaudio;webrtc_aecm;dtls_srtp;opus;g711;gzrtp;stun;turn;ice;presence;mwi;mixminus;account;natpmp;srtp;uuid;sndfile;debug_cmd;avformat;snapshot"
APP_MODULES := "g729"
```

## 4. 下载源码

### 4.1 一键下载全部依赖

```bash
make download-sources
```

该目标会先清空本地旧目录，再 `git clone --single-branch` 并执行 `make patch-src`：

| 目录 | 仓库 | 分支/Tag |
|---|---|---|
| `amr` | `https://git.code.sf.net/p/opencore-amr/code` | `v0.1.6` |
| `baresip` | `https://git.xswitch.cn/xyt/baresip.git` | `k120-and-update` |
| `bcg729` | `https://github.com/BelledonneCommunications/bcg729.git` | `release/1.1.1` |
| `codec2` | `https://github.com/drowe67/codec2.git` | `1.2.0` |
| `g722` | `https://github.com/sippy/libg722.git` | `v1.2.2` |
| `g7221` | `https://github.com/freeswitch/libg7221.git` | `master` |
| `openssl` | `https://github.com/openssl/openssl.git` | `openssl-3.5` |
| `opus` | `https://github.com/xiph/opus.git` | `v1.4` |
| `re` | `https://git.xswitch.cn/xswitch/re.git` | `k120-and-update` |
| `sndfile` | `https://github.com/juha-h/libsndfile.git` | `master` |
| `vo-amrwbenc` | `https://git.code.sf.net/p/opencore-amr/vo-amrwbenc` | `master` |
| `zrtpcpp` | `https://github.com/juha-h/ZRTPCPP.git` | `master` |
| `png` | `https://github.com/pnggroup/libpng.git` | `v1.6.48` |
| `ffmpeg-android-maker` | `https://github.com/Javernaut/ffmpeg-android-maker.git` | `master` |
| `libyuv` | `https://chromium.googlesource.com/libyuv/libyuv` | `main` |

> 注意：`baresip` / `re` 已改为 **HTTPS** 拉取，无需配置 SSH Key。旧的 `git@git.xswitch.cn:` 形式已废弃。

### 4.2 单独下载 webrtc

`webrtc` 不在 `download-sources` 中，需单独执行（依赖本地 `abseil-cpp/absl`）：

```bash
make download-webrtc
# 等价于:
# git clone https://github.com/chucongqing/libwebrtc -b mobile --single-branch webrtc
# cp -r abseil-cpp/absl webrtc/jni/src/webrtc
```

### 4.3 自动补丁

`make download-sources` 最后会自动执行：

```bash
make patch-src
# patch -d g7221 -p1 < g7221-patch
# patch -d re -p1 < re-patch
# patch -d ffmpeg-android-maker -p1 < ffmpeg-android-maker.patch
```

若手动更新了上述仓库，需重新执行 `make patch-src`。

执行完成后，根目录下应出现：`amr`, `baresip`, `bcg729`, `codec2`, `g722`, `g7221`, `openssl`, `opus`, `re`, `sndfile`, `vo-amrwbenc`, `zrtpcpp`, `png`, `ffmpeg-android-maker`, `libyuv`, `webrtc`, `abseil-cpp` 等。

## 5. 编译

### 5.1 完整编译流程

依赖关系：`libbaresip-deps` (openssl/opus/ffmpeg/libyuv/webrtc/...) → `libre.a` → `libbaresip`

```bash
# 方式一：脚本一键编译当前默认架构 (arm64-v8a) 并打包
./build.sh
# 等价于: make libre.a && make libbaresip && zip -r gdist.zip distribution.video

# 方式二：Makefile 单步
make libre.a ANDROID_TARGET_ARCH=arm64-v8a
make libbaresip ANDROID_TARGET_ARCH=arm64-v8a

# 方式三：多架构
make all    # arm64-v8a (当前 Makefile 默认仅 arm64-v8a)
make debug  # 额外编译 x86_64 (用于模拟器调试)

# 指定架构编译单个库，例如只编译 opus
make opus ANDROID_TARGET_ARCH=armeabi-v7a
```

各子目标可单独编译：`make amr|codec2|g729|g722|g7221|gzrtp|openssl|opus|sndfile|png|ffmpeg|libyuv|webrtc|libre.a|libbaresip`

### 5.2 产物

全部安装到 `distribution.video/`：

```
distribution.video/
├── baresip/lib/<ABI>/libbaresip.a + include/baresip.h
├── re/lib/<ABI>/libre.a + include/ + cmake/
├── openssl/lib/<ABI>/libcrypto.a, libssl.a + include/
├── opus/lib/<ABI>/libopus.a
├── ffmpeg/lib/<ABI>/*.so + include/
├── libyuv/lib/<ABI>/libyuv.a + include/
├── webrtc/lib/<ABI>/libwebrtc.a
├── amr / g729 / g722 / g7221 / codec2 / gzrtp / sndfile / png ...
└── gdist.zip  # build.sh 生成的打包文件
```

编译时使用的工具链均为 `$(NDK_PATH)/toolchains/llvm/prebuilt/$(HOST_OS)/bin/<CLANG_TARGET><API_LEVEL>-clang` 等，`CMAKE_ANDROID_FLAGS` 已封装 `android.toolchain.cmake`。

### 5.3 清理

```bash
make clean
# 清理各子项目的 build/.cache/output 等
```

## 6. 常见问题

* **NDK 版本不匹配**：确保 `NDK_PATH` 指向 `r27c`，且 `app/build.gradle.kts` 中 `ndkVersion` 一致。
* **SSH 拉取失败**：本仓库已统一为 `https://git.xswitch.cn/...`，无需 `~/.ssh` 配置；若仍使用旧 remote，请 `git remote set-url origin https://git.xswitch.cn/xyt/baresip.git`。
* **`ffmpeg-android-maker` 失败**：检查 `SDK_PATH` / `NDK_PATH` 是否正确，以及 `ANDROID_SDK_HOME`/`ANDROID_NDK_HOME` 传递。
* **`webrtc` 缺少 `absl`**：需保证 `abseil-cpp` 目录存在，`make download-webrtc` 会自动拷贝 `abseil-cpp/absl` 到 `webrtc/jni/src/webrtc`。

## 7. 目录说明

```
Makefile                 # 主编译脚本
build.sh                 # 一键编译 + 打包脚本
g7221-patch / re-patch / ffmpeg-android-maker.patch  # 针对上游的本地补丁
abseil-cpp/              # webrtc 依赖
distribution.video/      # 编译产物 (gitignored)
baresip / re / openssl ... # 下载的源码 (gitignored)
```
