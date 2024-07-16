#!/bin/bash -ex

# device removable media happens to be plugged into
# like /dev/sdc1
dev=$1

sudo apt install e2fsprogs pmount
sudo e2label /dev/sdc1 xfer
pmount /dev/disk/by-label/xfer xfer
mkdir -p /media/xfer/Videos/veyepar/pyohio/pyohio_2024/dv
pumount xfer
