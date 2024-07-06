#!/bin/bash -ex

# mkpi.sh - flashes and configs an SD card for pi

# https://elinux.org/RPiconfig
# https://github.com/RPi-Distro/raspi-config/issues/55
# https://github.com/raspberrypi-ui/rc_gui/blob/master/src/rc_gui.c#L23
# https://www.raspberrypi.org/forums/viewtopic.php?t=5851
# https://www.raspberrypi.org/documentation/remote-access/ssh/
# https://www.raspberrypi.org/documentation/configuration/screensaver.md
# https://www.raspberrypi.org/documentation/configuration/config-txt/video.md

#dlurl=http://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04-preinstalled-server-armhf+raspi.img.xz
# dlurl=http://cdimage.ubuntu.com/ubuntu-server/daily-preinstalled/current/groovy-preinstalled-server-armhf+raspi.img.xz
# dlurl=http://cdimage.ubuntu.com/ubuntu-server/daily-preinstalled/current/groovy-preinstalled-server-arm64+raspi.img.xz
# dlurl=https://raspi.debian.net/daily/raspi_3.img.xz
# dlurl=https://raspi.debian.net/verified/20200501_raspi_3.img.xz

# dlurl=http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2020-05-28/2020-05-27-raspios-buster-lite-armhf.zip

# dlurl=https://raspi.debian.net/tested/20210823_raspi_4_bullseye.img.xz

# http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-04-07/2022-04-04-raspios-bullseye-armhf-lite.img.xz
# raspios_lite_armhf/images/raspios_lite_armhf-2022-04-07
# 2022-04-04-raspios-bullseye-armhf-lite.img.xz

# http://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2022-04-07/2022-04-04-raspios-bullseye-armhf-full.img.xz

img_host=http://downloads.raspberrypi.org

# img_path=raspios_full_armhf/images/raspios_full_armhf-2022-04-07
# base_name=2022-04-04-raspios-bullseye-armhf-full.img

# img_path=raspios_lite_armhf/images/raspios_lite_armhf-2023-05-03
# base_name=2023-05-03-raspios-bullseye-armhf-lite.img

# img_path=raspios_full_armhf/images/raspios_full_armhf-2023-05-03/
# base_name=2023-05-03-raspios-bullseye-armhf-full.img

# img_path=raspios_lite_armhf/images/raspios_lite_armhf-2023-12-11
# base_name=2023-12-11-raspios-bookworm-armhf-lite.img

# img_path=raspios_lite_arm64/images/raspios_lite_arm64-2023-12-11
# base_name=2023-12-11-raspios-bookworm-arm64-lite.img

img_path=raspios_lite_armhf/images/raspios_lite_armhf-2024-03-15
base_name=2024-03-15-raspios-bookworm-armhf-lite.img

zip_name=${base_name}.xz
# user=pi

# dev=mmcblk0
dev=sda

cache=cache

# url=$(curl -w "%{json}" --head https://downloads.raspberrypi.org/raspbian_latest |tail --lines 1 |  jq .redirect_url)
# if [ $(basename $url) = $base_name ]; then exit fi

(cd ${cache}

# wget -N http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-04-09/2019-04-08-raspbian-stretch-lite.zip

# wget -N http://downloads.raspberrypi.org/raspbian_full/images/raspbian_full-2019-07-12/2019-07-10-raspbian-buster-full.zip

# wget -N http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-07-12/2019-07-10-raspbian-buster-lite.zip
# http://downloads.raspberrypi.org/raspbian/images/raspbian-2020-02-14/2020-02-13-raspbian-buster.zip
# http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip
# wget -N http://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz

wget -N ${img_host}/${img_path}/${zip_name}
)

# img=2019-04-08-raspbian-stretch-lite.zip
# img=2019-07-10-raspbian-buster-full.zip
# img=2019-07-10-raspbian-buster-lite.zip
# img=2020-02-13-raspbian-buster-lite.zip
# img=ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz
# img=ubuntu-20.04-preinstalled-server-armhf+raspi.img.xz
# img=groovy-preinstalled-server-armhf+raspi.img.xz
# img=groovy-preinstalled-server-arm64+raspi.img.xz
# img=raspi_3.img.xz
# img=20200501_raspi_3.img.xz
# img=2020-05-27-raspios-buster-lite-armhf.zip

# img=20210823_raspi_4_bullseye.img.xz


# hname=smpi
# hname=cc
# hname=krakensdr

hname=$1

for p in /dev/${dev}* # p?
    do pumount $p || true
done

# time zcat ${cache}/${zip_name}|sudo dcfldd of=/dev/$dev
time xz --decompress --stdout ${cache}/${zip_name}|sudo dcfldd of=/dev/$dev

# mount the partitions under /media/boot and /media/rootfs
sudo partprobe /dev/${dev}
sleep 1

# pmount ${dev}p1 boot
# pmount ${dev}p2 rootfs
pmount ${dev}1 boot
pmount ${dev}2 rootfs

# backup old conf
sudo cp /media/boot/config.txt /media/boot/config.org
# hdmi settings: (ignore edid, 1080p, overscan)
# sudo cp config/bigtv_config.txt /media/boot/config.txt
# enable serial for console
# sudo cp config/config.txt /media/boot/config.txt

# don't resize
# cp /media/boot/cmdline.txt /tmp
# (never mind, let it resize)
# sudo cp config/cmdline.txt /media/boot/

# don't blank the console after timeout
sudo printf " consoleblank=0" >> /media/boot/cmdline.txt

# set the keybarod to US
sudo cp config/keyboard /media/rootfs/etc/default

# show IP and other stuff on console
sudo cp config/issue /media/rootfs/etc/

# use carl's local .deb cache:
# sudo cp config/30autoproxy /media/rootfs/etc/apt/apt.conf.d

# disable pw, port 22129
# sudo cp config/sshd_local.conf /media/rootfs/etc/ssh/sshd_config.d/

# set hostname
sudo sed -i "s/raspberrypi/${hname}/" /media/rootfs/etc/hostname
sudo sed -i "s/raspberrypi/${hname}/" /media/rootfs/etc/hosts

# when sshed in, make gui stuff run on the pi's display
# printf "\nexport DISPLAY=:0.0\n">>/media/rootfs/home/pi/.bashrc

sync
sleep 5
for p in /dev/${dev}*[12]
    do pumount $p || true
done

echo sudo rsync -LP ${cache}/${zip_name} /media/carl/rootfs/root/files/
echo Dont "forget to fixit.sh (ssh keys...)"

exit


# ssh-keygen
# ssh-import-id gh:carlfk
# ssh-copy-id https://github.com/carlfk.keys

# sudo passwd pi

# expand fs
# set locale to en_US
# keyboard-layout
# timezone

# no resizefs on boot
# (so that more can be done,
# then re-enable, then image the smaller image)
cp config/cmdline.txt /media/boot

cp 1280x720_input.png /media/root/home/pi

mkdir /media/root/home/pi/temp /media/root/home/pi/bin
cd /media/root/home/pi/bin
# wget https://github.com/numato/samplecode/raw/master/RelayAndGPIOModules/USBRelayAndGPIOModules/python/usbrelay1_2_4_8/relaywrite.py
# wget https://github.com/numato/samplecode/raw/master/RelayAndGPIOModules/USBRelayAndGPIOModules/python/usbrelay1_2_4_8/relayread.py

cd ..
cp ~/src/Ripley-1/setup/setup.sh .


sync
sleep 5
for p in /dev/${dev}p?
    do pumount $p || true
done

