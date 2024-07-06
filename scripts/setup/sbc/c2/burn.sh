#!/bin/bash -ex

# do this better
for file in /media/juser/*; do
	echo umount "$file"
done
sync

img=ubuntu-18.04-3.16-minimal-odroid-c2-20180626.img.xz
dev=sdd

if [ ! -b "/dev/${dev}" ]; then
  echo "error: /dev/${dev} is not a block device."
  exit
fi

wget -N https://odroid.in/ubuntu_18.04lts/${img}
wget -N https://odroid.in/ubuntu_18.04lts/${img}.md5sum
md5sum --check ${img}.md5sum

xz --decompress --stdout ${img}|sudo dcfldd status=on bs=4M of=/dev/$dev

sync
sleep 5
sync

