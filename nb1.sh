#!/bin/sh

# Color Code Script
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White
nocol='\033[0m'         # Default

echo -e "$Red  Kernel For ( HMD Global ) Nokia 8  $nocol"

if [ ! -d ~/android_kernel_wireguard ]; then
echo -e "$Cyan  Cloning Wireguard Repository  $nocol"
git clone https://git.zx2c4.com/android_kernel_wireguard ~/android_kernel_wireguard
echo -e "$Green  Wireguard Repository Cloned  $nocol"
else
echo -e "$Green  Wireguard Repository Already Present  $nocol"
fi

echo -e "$Blue  Applying Wireguard Patch $nocol"

if grep -q 'net/wireguard/Kconfig' net/Kconfig; then
echo -e "$Green  Wireguard Patches Are Already Applied  $nocol"
else
. ~/android_kernel_wireguard/patch-kernel.sh $(pwd)
echo -e "$Green  Wireguard Patch Applied  $nocol"
fi

if [ ! -d ~/aarch64-linux-android-4.9 ]; then
echo -e "$Cyan  Cloning UberTC Repository  $nocol"
git clone https://bitbucket.org/matthewdalex/aarch64-linux-android-4.9 ~/aarch64-linux-android-4.9
echo -e "$Green  UberTC Repository Cloned  $nocol"
else
echo -e "$Green  UberTC Repository Already Present  $nocol"
fi

if [ ! -d ~/linux-x86 ]; then
echo -e "$Cyan  Cloning Clang Repository  $nocol"
git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 ~/linux-x86
echo -e "$Green  Clang Repository Cloned  $nocol"
else
echo -e "$Green  Clang Repository Already Present  $nocol"
fi

echo -e "$Blue  Setting Up Toolchain $nocol"
export CROSS_COMPILE="/home/$(whoami)/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
echo -e "$Yellow  Setting Up Architecture  $nocol"
export ARCH=arm64 && export SUBARCH=arm64
echo -e "$Green  Toolchain Path Exported  $nocol"

echo -e "$Red  Starting Compilation  $nocol"
export KBUILD_BUILD_USER="Hmd"
export KBUILD_BUILD_HOST="Nokia"
rm -rf out
mkdir -p out/
echo -e "$Cyan  Copying dts  $nocol"
mkdir -p out/arch/arm64/
cp -r arch/arm64/boot out/arch/arm64/
rm -rf out/arch/arm64/boot/dts/qcom
mkdir -p out/arch/arm64/boot/dts/qcom/
cp arch/arm64/boot/dts/qcom/*.dts* out/arch/arm64/boot/dts/qcom/
echo -e "$Green  Making Clean  $nocol"
make O=out/ clean
make O=out/ mrproper 
echo -e "$Green  Setting Up Deconfig  $nocol"
make O=out/ NB1_defconfig 
echo -e "$Red  Compilation Started  $nocol"
make -j$(nproc --all) O=out \
                                    CC="/home/$(whoami)/linux-x86/clang-r328903/bin/clang" \
                                    CLANG_TRIPLE=aarch64-linux-gnu- \




