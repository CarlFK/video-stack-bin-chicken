#!/bin/sh

set -efux

server=$1

# the original server gets passed in
# in case we need it for something.
# in this file, we don't.
# The stock late_command.sh has already been wget to target/tmp
# late_command.sh wget and called this script
# We will call late_command.sh again with a different server
# which will point it to different ansible playbook/inventory.

# Do random things to the target before the ansible
apt install -y ssh-import-id pmount
ssh-import-id lp:CarlFK

# get late_command.cfg from some other server.
# (like the one hosting this late_command2.sh)
# note: late_command.sh is going to wget some other files too.
# so a copy of those few files need to be hosted also.
# or get fancy and redirect to https://salsa.debian.org/debconf-video-team/ansible/raw/master/roles/pxe/tftp-server/files/

server=veyepar.NextDayVideo.com

unset lc2_url
/tmp/late_command.sh ${server}

