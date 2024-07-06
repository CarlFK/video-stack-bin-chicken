#!/bin/bash -ex

# to use different Ansible playbook and inventory repos.
# hook the stock debconf-video-team process by passing lc2_url
# to the installer.

# what the hook does is up to you.
# Here is what I find pretty OK.


mkdir scripts
cd scripts

stock=https://salsa.debian.org/debconf-video-team/ansible/raw/master/roles/pxe/tftp-server/files/scripts
for fn in ansible-firstboot.service  ansible-firstboot.sh  ansible-up late_command.cfg
do
  wget ${stock}/${fn}
done

hook_loc=https://github.com/CarlFK/video-stack-bin-chicken/raw/master/scripts/setup/lc2
wget ${hook_loc}/late_command2.sh

