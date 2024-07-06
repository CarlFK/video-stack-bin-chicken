#!/bin/bash -ex

# instructions:
# mount sdcard's / on somewhere (rootfs)
# maybe mount sd card's /boot under somewhere/boot or boot/firmware
# run me: ~/sbc/fixit.sh /media/carl rootfs bootfs

# /dev/sda1 /media/carl/bootfs
# /dev/sda2 /media/carl/rootfs

mntdir=${1:-/media/carl}
rootfs=${mntdir}/${1:-rootfs}
bootfs=${mntdir}/${2:-bootfs}

# sudo apt install pwgen

user=pi
# user=orangepi
# user=videoteam

userdir=${rootfs}/home/${user}

flavor=rpi
# flavor=orange
# flavor=c2

# set hostname to $hname (later)
hname=${flavor}

# ansible roles (where some handy stuff lives)
aroles=~/src/tv/pib/pici/ansible/roles

# sanity checks to make sure the image is mounted where we say it is.
# and this too:
# src=$(dirname $0)/${flavor}
src=$PWD/${flavor}
if  [ ! -d "${src}" ]; then
    echo "${src} does not exist."
    echo $0
    dirname $0
    exit
fi

if  [ ! -d "${rootfs}/root/" ]; then
    echo ${rootfs}/root/ does not exist.
    ls -l
    exit
fi

if  [ ! -d ${userdir} ]; then
    echo ${userdir} does not exist.
    ls -l home
    exit
fi

# enable ssh,
sudo touch ${bootfs}/ssh
# define user/password
# sudo ${aroles}/fixpi/files/pipw.sh ${user} x ${bootfs}
sudo ${aroles}/fixpi/files/pipw.sh fpgadmin Poog3koo ${bootfs}

(
cd ${rootfs}

# show IP and other stuff on console
sudo cp ${src}/config/issue etc/

# use carl's local .deb cache:
# sudo cp config/30autoproxy etc/apt/apt.conf.d

# cp keys from local user

# sshd.conf: disable pw, port 22129
# sudo cp config/sshd_local.conf etc/ssh/sshd_config.d/

sudo mkdir -p root/.ssh
sudo ssh-keygen -f root/.ssh/id_rsa # -P huh

sudo cp ~/.ssh/id_rsa.pub root/.ssh/authorized_keys
sudo chown -R --reference=root root/.ssh
# sudo cp config/ssh/authorized_keys /media/rootfs/root/.ssh/authorized_keys
# sudo cp config/ssh/authorized_keys /media/rootfs/home/${user}/.ssh/authorized_keys

# sudo mkdir -p ${userdir}/.ssh
# sudo ssh-keygen -f ${userdir}/.ssh/id_rsa # -P duh

# sudo cp ~/.ssh/id_rsa.pub ${userdir}/.ssh/authorized_keys
# sudo chown -R --reference=${userdir} ${userdir}/.ssh

# set hostname
sudo sed -i "s/raspberrypi/${hname}/" etc/hostname
sudo sed -i "s/raspberrypi/${hname}/" etc/hosts

sudo cp ${aroles}/fixpi/files/etc/keyboard etc/default/keyboard

# when sshed in, make gui stuff run on the pi's display
printf "\nexport DISPLAY=:0.0\n">>home/pi/.bashrc

sync
sleep 5

# sudo umount boot/firmware/
)

pumount ${bootfs}
pumount ${rootfs}

exit

# $dev is no longer used, so this is pointless
for p in /dev/${dev}*[12]
    do pumount $p || true
done

echo sudo rsync -LP ${cache}/${zip_name} /media/carl/rootfs/root/files/

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

