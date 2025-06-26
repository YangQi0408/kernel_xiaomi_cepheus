#!/bin/bash

ANYKERNEL3_DIR=$PWD/Anykernel/
FINAL_KERNEL_ZIP=InfiniR_cepheus_v1.39_KSUN.zip

TOOLCHAIN_PATH="/home/yangqi/toolchains/proton-clang/bin"

export LLVM=1
export USE_CCACHE=1
export PATH="$TOOLCHAIN_PATH:$PATH"
export CCACHE_DIR="$HOME/.cache/ccache_xm9kernel" 
export PATH="/usr/bin/ccache:$PATH"
echo "CCACHE_DIR: [$CCACHE_DIR]"

ccache --version
ccache -s
clang -v
which clang

MAKE_ARGS="AR=llvm-ar \
        AS=as \
        ARCH=arm64 \
        SUBARCH=arm64 \
        O=out \AR=llvm-ar \
        LD=ld.lld \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
        CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
        CLANG_TRIPLE=aarch64-linux-gnu-"

make AS=as CC="ccache clang" CXX="ccache clang++" $MAKE_ARGS cepheus_defconfig -j12

START=$(date +"%s")

make AS=as CC="ccache clang" CXX="ccache clang++" $MAKE_ARGS -j12

echo -e "$yellow**** Verify Image.gz-dtb ****$nocol"
ls $PWD/out/arch/arm64/boot/Image.gz-dtb

echo -e "$yellow**** Verifying AnyKernel3 Directory ****$nocol"
ls $ANYKERNEL3_DIR
echo -e "$yellow**** Removing leftovers ****$nocol"
rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP

echo -e "$yellow**** Copying Image.gz-dtb ****$nocol"
cp $PWD/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL3_DIR/

echo -e "$yellow**** Time to zip up! ****$nocol"
cd $ANYKERNEL3_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cp $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP /home/yangqi/kernel/$FINAL_KERNEL_ZIP

echo -e "$yellow**** Done, here is your checksum ****$nocol"
cd ..
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP
rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
rm -rf out/

END=$(date +"%s")
DIFF=$((END - START))
echo -e '\033[01;32m' "Kernel compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds" || exit
sha1sum $KERNELDIR/$FINAL_KERNEL_ZIP
