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
dlurl=https://raspi.debian.net/verified/20200501_raspi_3.img.xz

dlurl=http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2020-05-28/2020-05-27-raspios-buster-lite-armhf.zip

# https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip

cache=cache

(cd ${cache}

# wget -N http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-04-09/2019-04-08-raspbian-stretch-lite.zip

# wget -N http://downloads.raspberrypi.org/raspbian_full/images/raspbian_full-2019-07-12/2019-07-10-raspbian-buster-full.zip

# wget -N http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-07-12/2019-07-10-raspbian-buster-lite.zip
# http://downloads.raspberrypi.org/raspbian/images/raspbian-2020-02-14/2020-02-13-raspbian-buster.zip
# http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip
# wget -N http://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz

wget -N ${dlurl}
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
img=2020-05-27-raspios-buster-lite-armhf.zip

dev=mmcblk0
# dev=sdc


# user=ubuntu
user=pi

# hname=smpi
hname=cc

for p in /dev/${dev}* # p?
    do pumount $p || true
done

time zcat ${cache}/$img|sudo dcfldd of=/dev/$dev
# time xz --decompress --stdout ${cache}/$img|sudo dcfldd of=/dev/$dev

# mount the partitions under /media/boot and /media/rootfs
sudo partprobe /dev/${dev}
sleep 1

pmount ${dev}p1 boot
# pmount ${dev}1 boot
pmount ${dev}p2 rootfs

# backup old conf
# sudo mv /media/boot/config.txt /media/boot/config.org
# hdmi settings: (ignore edid, 1080p, overscan)
# sudo cp config/bigtv_config.txt /media/boot/config.txt

# don't resize
# cp /media/boot/cmdline.txt /tmp

# (never mind, let it resize)
# sudo cp config/cmdline.txt /media/boot/

# don't blank the console after timeout
sudo printf " consoleblank=0" >> /media/boot/cmdline.txt

sudo cp config/keyboard /media/rootfs/etc/default
sudo cp config/issue /media/rootfs/etc/
sudo cp config/30autoproxy /media/rootfs/etc/apt/apt.conf.d

# enable ssh, cp keys from local user
sudo touch /media/boot/ssh

sudo mkdir -p /media/rootfs/root/.ssh
sudo ssh-keygen -f /media/rootfs/root/.ssh/id_rsa -P score

sudo mkdir -p /media/rootfs/home/${user}/.ssh
sudo ssh-keygen -f /media/rootfs/home/${user}/.ssh/id_rsa -P score

# sudo cp ~/.ssh/id_rsa.pub /media/rootfs/root/.ssh/authorized_keys
sudo cp config/ssh/authorized_keys /media/rootfs/root/.ssh/authorized_keys
sudo cp config/ssh/authorized_keys /media/rootfs/home/${user}/.ssh/authorized_keys
sudo chown -R --reference=/media/rootfs/home/${user} /media/rootfs/home/${user}/.ssh

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

