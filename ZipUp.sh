#!/bin/bash


BUILD_START=$(date +"%s")
blue='\033[1;34m'
yellow='\033[1;33m'
nocol='\033[0m'
green='\033[1;32m'
KERNELDIR=$PWD

#KERNEL_DEFCONFIG=alioth-Kali_defconfig

ANYKERNEL3_DIR=$PWD/AnyKernel3/

echo -e "Enter the desired name for the final kernel zip file (<kernel_name>.zip): "
read -rp "Enter final Kernel name: " FINAL_KERNEL_ZIP 



echo -e "$yellow**** Verify Image ****$nocol"
ls $PWD/out/arch/arm64/boot/Image
#ls $PWD/out/arch/arm64/boot/dtbo.img

echo -e "$yellow**** Verifying AnyKernel3 Directory ****$nocol"
ls $ANYKERNEL3_DIR

echo -e "$blue**** Removing leftovers ****$nocol"
rm -rf $ANYKERNEL3_DIR/Image
#rm -rf $ANYKERNEL3_DIR/dtbo.img
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP
rm -rf $KERNELDIR/$FINAL_KERNEL_ZIP

echo -e "$yellow**** Copying Image ****$nocol"
cp $PWD/out/arch/arm64/boot/Image $ANYKERNEL3_DIR/
#cp $PWD/out/arch/arm64/boot/dtbo.img $ANYKERNEL3_DIR/

echo -e "$blue **** Time to zip up! ****$nocol"
cd $ANYKERNEL3_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cp $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP $KERNELDIR/$FINAL_KERNEL_ZIP

echo -e "$green**** Done, here is your checksum ****$nocol"
cd ..
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP
rm -rf $ANYKERNEL3_DIR/Image
#rm -rf $ANYKERNEL3_DIR/dtbo.img
#rm -rf out/

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$green Zipped in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
sha1sum $KERNELDIR/$FINAL_KERNEL_ZIP
