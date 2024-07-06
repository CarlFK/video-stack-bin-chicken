#!/bin/bash -ex

img=$1

# dev=/mmcblk0
dev=sda

for p in /dev/${dev}*
    do pumount $p || true
done

# img=2018-03-13-raspbian-stretch-lite.zip
# img=ubuntu64-16.04-minimal-odroid-c2-20160815.img.xz
# img=Debian-Stretch64-0.9.1-20170624-C2.img
# img=2018-06-27-raspbian-stretch-lite.zip
# img=odroid/ubuntu/ubuntu-18.04-3.16-minimal-odroid-c2-20180626.img.xz
# img=odroid/armbian/Armbian_5.78_Aml-s905_Debian_stretch_default_5.1.0-rc1_20190409.img.xz
# img=odroid/armbian/Debian_stretch_next.7z
# img=odroid/ubuntu/ubuntu-20.04-3.16-minimal-odroid-c2-20210201.img.xz

# img=rpi/2019-07-10-raspbian-buster-full.zip
# img=rpi/2019-07-10-raspbian-buster-lite.zip
# img=Orange/Orangepipc_2.0.8_debian_buster_server_linux5.4.65.7z

# img=rpi/kraken/krakensdr_pi4_101122.img.xz
# img=rpi/kraken/rpi34_kerberossdr_image_18022020.zip

# dcfldd bs=4M if=2013-05-25-wheezy-raspbian.img of=/dev/mmcblk0
# time dcfldd status=on bs=4M if=$1 of=/dev/mmcblk0
# time zcat $img|sudo dcfldd of=/dev/$dev
# time unzip -p $img|sudo dcfldd of=/dev/$dev
time xz --decompress --stdout $img|sudo dcfldd of=/dev/$dev
# time dcfldd status=on bs=4M if=$img of=/dev/$dev
# 7za e $img -so |sudo dcfldd of=/dev/$dev

sync
sleep 5
sync

