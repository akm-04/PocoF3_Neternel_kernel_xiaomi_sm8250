#!/bin/bash

#set -e

# Speed up build process
# MAKE="./makeparallel"

BUILD_START=$(date +"%s")
blue='\033[1;34m'
yellow='\033[1;33m'
nocol='\033[0m'
green='\033[1;32m'
KERNELDIR=$PWD


echo -e " $yellow ##### This requires that you've already installed ########$nocol "
echo -e " $yellow ##### CROSS_Compiler and clang globally. If you ##########$nocol "
echo -e " $yellow ##### want to export path to toolchain, please edit ######$nocol "
echo -e " $yellow ##### this build.sh and uncomment export lines. This #####$nocol "
echo -e " $yellow ##### also requires that 'Anykernel3' folder is inside ###$nocol "
echo -e " $yellow ##### the root of kernel source folder and anykernel.sh ##$nocol "
echo -e " $yellow ##### is configured correctly according to the device ####$nocol "

#echo -e " $yellow ##### This script requires that proton-clang & AnyKernel3 #####$nocol "
#echo -e " $yellow ##### is copied inside the $KERNELDIR folder ###########$nocol"
#echo -e " $yellow ##### and that the anykernel.sh is configured correctly ########$nocol"

# If using export, please uncomment these lines
#sudo apt-get update && sudo apt-get install llvm lld lldb clang gcc binutils flex bison build-essential git gcc g++ gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-linux-gnueabi




echo -e "Enter the desired name for the final kernel zip file (<kernel_name>.zip): "
read -rp "Enter final Kernel name: " FINAL_KERNEL_ZIP 


KERNEL_DEFCONFIG=akm_alioth-Kali_defconfig
ANYKERNEL3_DIR=$PWD/AnyKernel3/
#FINAL_KERNEL_ZIP=NetErnel_LineageOS-20.zip
export ARCH=arm64
#export PATH="$PWD/proton-clang/bin:${PATH}" 

echo -e "$green***Your Clang Version is $nocol"
clang --version



# Always do clean build lol
echo -e "$yellow**** Cleaning / Removing 'out' folder ****$nocol"
#make clean		# Can cause issues
#make mrproper	# Can cause issues
rm -rf out
mkdir -p out
#make O=out clean  	# Unecessary after running rm -rf out
#make O=out mrproper	# Unecessary

echo -e "$yellow**** Kernel defconfig is set to $KERNEL_DEFCONFIG ****$nocol"
echo -e "$blue***********************************************"
echo "       NOW MAKING _defconfig : $KERNEL_DEFCONFIG        "
echo -e "***********************************************$nocol"
make O=out CC=clang $KERNEL_DEFCONFIG 



echo -e "$blue***********************************************"
echo "         NOW COMPILING KERNEL!                  "
echo -e "***********************************************$nocol"

make O=out \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi \
        CC=clang \
        -j4 2>&1 | tee build.log
        #AR=llvm-ar \
        #NM=llvm-nm \
        #OBJCOPY=llvm-objcopy \
        #OBJDUMP=llvm-objdump \
        #STRIP=llvm-strip \
        
  #  $(nproc)


### Other options that could be used if using protom clamg for example..


        #CROSS_COMPILE=aarch64-linux-gnu- \
        #CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
        # CC=clang \
        # AR=llvm-ar \
        # OBJDUMP=llvm-objdump \
        # STRIP=llvm-strip \
        
      # CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
      #  NM=llvm-nm \
      #  OBJCOPY=llvm-objcopy \

BUILD_MID=$(date +"%s")
MID_DIFF=$(($BUILD_MID - $BUILD_START))
echo -e "$yellow  Compiled the kernel in $(($MID_DIFF / 60)) minute(s) and $(($MID_DIFF % 60)) seconds.$nocol"



echo -e "$green***********************************************"
echo "   COMPILING FINISHED! NOW MAKING IT INTO FLASHABLE ZIP "
echo -e "***********************************************$nocol" 




echo -e "$yellow**** Verify that Image is produced ****$nocol"

ls $PWD/out/arch/arm64/boot/Image
#ls $PWD/out/arch/arm64/boot/dtbo.img


echo -e "$yellow**** Verifying AnyKernel3 Directory ****$nocol"
ls $ANYKERNEL3_DIR


echo -e "$yellow**** Removing leftovers from anykernel3 folder ****$nocol"


rm -rf $ANYKERNEL3_DIR/Image
#rm -rf $ANYKERNEL3_DIR/dtbo.img
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP
rm -rf $KERNELDIR/$FINAL_KERNEL_ZIP

echo -e "$yellow**** Copying Image to anykernel 3 folder ****$nocol"


cp $PWD/out/arch/arm64/boot/Image $ANYKERNEL3_DIR/
#cp $PWD/out/arch/arm64/boot/dtbo.img $ANYKERNEL3_DIR/

echo -e "$green**** Time to zip up! ****$nocol"


cd $ANYKERNEL3_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cp $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP $KERNELDIR/$FINAL_KERNEL_ZIP

echo -e "$green**** Done, here is your checksum ****$nocol"


cd ..
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP
rm -rf $ANYKERNEL3_DIR/Image
#rm -rf $ANYKERNEL3_DIR/dtbo.img
rm -rf out/

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$green Full Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
sha1sum $KERNELDIR/$FINAL_KERNEL_ZIP
