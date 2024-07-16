#!/bin/bash -ex

opts="$@"

pmount /dev/disk/by-label/xfer xfer
time videoteam-copy-recordings.sh ${opts}
sync
pumount xfer
sync
