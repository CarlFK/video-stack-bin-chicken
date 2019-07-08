#!/bin/bash -ex

# scp lca-setup.sh lca-setup_eth.cfg 01-netcfg.yaml juser@gator:
# sudo mv lca-setup_eth.cfg /etc/network/interfaces.d/
# sudo mv 01-netcfg.yaml /etc/netplan/
# sudo netplan apply

# stop vocto
# stop-all-the-things

CPU=${1:-mor1kx}

# stuff needed cuz minimal install
sudo apt -y install pmount libx11-6 # ifupdown

# quick copy from local drive of:
# Vivado and key
# https://github.com/mithro/linux-litex.git

if [[ -z $xdisk || -z $nic ]]; then
  set +x
  echo set xdisk and nic:
  echo vim ~/.bashrc
  echo export xdisk=sda1
  echo export nic=enp3s0 enp0s31f6
  exit
fi

sudo ip addr del 192.168.100.100/24 dev $nic || true

sudo adduser $USER video
sudo adduser $USER dialout

if [ ! -d /opt/Xilinx ]; then

    pmount ${xdisk}

    mkdir -p local
    (cd local
    # xsetup -b Install \
    #    -a XilinxEULA,3rdPartyEULA,WebTalkTerms \
    #    -c install_config.txt
    tar --keep-newer-files -xvf /media/${xdisk}/tv/xilinx/Vivado_2018.3.tbz
    # rsync -trvP /media/${xdisk}/tv/xilinx/Xilinx .
    sudo ln -sf ~/local/Xilinx /opt
    # sudo chown $USER: /opt/Xilinx
    )

    rsync -trvP /media/${xdisk}/tv/xilinx/.Xilinx .

    rsync -trvP /media/${xdisk}/tv/linux-litex .

    pumount ${xdisk}

fi

export LD_LIBRARY_PATH=/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu:/opt/Xilinx/Vivado/2018.3/lnx64/tools/clang-3.9/lib

git -C linux-litex pull
export LINUX_GITLOCAL=~/linux-litex

mkdir -p tv
cd tv

sudo apt-get -y install build-essential libncurses5-dev gcc make git exuberant-ctags bc libssl-dev

if [ ! -d HDMI2USB-mode-switch ]; then
    git clone https://github.com/timvideos/HDMI2USB-mode-switch.git
fi
(cd HDMI2USB-mode-switch/udev
git pull
make install
sudo udevadm control --reload-rules
# need to triger for plugged in board:
# udevadm trigger [options] [devpath|file...]
)

if [ ! -d litex-buildenv ]; then
    git clone https://github.com/timvideos/litex-buildenv.git
fi

cd litex-buildenv
git pull

export CPU=${CPU} CPU_VARIANT= PLATFORM=arty TARGET=net FIRMWARE=firmware
./scripts/download-env.sh
source ./scripts/enter-env.sh

# make tftpd_stop
make gateware

sudo apt-get -y install atftpd libpixman-1-dev pkg-config libglib2.0-dev python-minimal libftdi-dev uml-utilities openvpn net-tools bison flex
sudo apt -y build-dep qemu
# export QEMU_REMOTE=https://github.com/stffrdhrn/qemu.git
# export QEMU_BRANCH=litex
echo 1 hdmi2usb on qemu
./scripts/build-qemu.sh

sudo apt-get -y install build-essential libncurses5-dev gcc make git exuberant-ctags bc libssl-dev

export CPU=${CPU} CPU_VARIANT=linux PLATFORM=arty TARGET=net FIRMWARE=linux
./scripts/build-linux.sh

make image

echo 2 linux on qemu
echo cat /proc/cpuinfo
echo cpu         : OpenRISC-0

./scripts/build-qemu.sh

# remove networking used by QEMU
sudo ip link delete dev tap0

sudo dmesg --clear
read -p "plug in Arty usb and hit Enter...."
sudo dmesg --read-clear

echo Now on arty

export CPU=${CPU} CPU_VARIANT=linux PLATFORM=arty TARGET=net FIRMWARE=firmware

# conda upgrade gcc-${CPU}-elf-newlib
# conda upgrade flterm

make gateware-load
make firmware-load

# hook Arty to lan
sudo ip addr add 192.168.100.100/24 dev ${nic}
sudo ip link set ${nic} up

make tftpd_start
make tftp

# boot hdmi2usb on Arty
make gateware-load

# conda upgrade gcc-${CPU}-elf-newlib
# conda upgrade flterm

make firmware-connect

export CPU=${CPU} CPU_VARIANT=linux PLATFORM=arty TARGET=net FIRMWARE=linux
make gateware
./scripts/build-linux.sh

make tftpd_stop
make tftpd_start
make tftp

# boot linux on Arty
make gateware-load

echo cat "/proc/cpuinfo"
echo cpu "architecture    : OpenRISC 1000 (1.1-rev0)"

make firmware-connect

