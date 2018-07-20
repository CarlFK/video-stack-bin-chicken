# mk_c2.sh
# sets up a C2 - keys for ansible and some extra atlys stuff
# https://wiki.debconf.org/wiki/Videoteam/SBC_for_Opsis#Round_4:_Carl_is_back

apt-get --assume-yes update
apt-get --assume-yes upgrade
apt-get --assume-yes install software-properties-common
apt-add-repository --yes ppa:timvideos/fpga-support
apt-get --assume-yes install \
    tio flterm fxload hdmi2usb-mode-switch hdmi2usb-udev \
    python python3-pkg-resources \
    usbutils vizzini-dkms voctomix-outcasts \
    vim

cat > /lib/udev/rules.d/85-local-atlys-fx2-firmware.rules <<EOF
# Load the hdmi2usb firmware onto the Atlys FX2 chip
SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="1443", ATTRS{idProduct}=="0007", RUN+="/sbin/fxload -D \$tempnode -t fx2lp -I /lib/firmware/hdmi2usb.hex"
EOF
touch /forcefsck
ip link show eth0
reboot
