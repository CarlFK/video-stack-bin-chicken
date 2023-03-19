#!/bin/bash -ex
# ans-it.sh
# ansible the x-box

# run from the dir that contains the playbook and inventory repos
# like this:
# cp ans-it.sh ../../..; cd ../../..; ./ans-it.sh cboxs cnt6

echo ./ans-it.sh dir hostname
echo ./ans-it.sh cboxs bare

inv_dir=$1
box=$2

inv_repo=video-stack-inventory
# inv_repo=video-stack-bin-chicken
# inv_repo=ansible

inventory_file=${inv_repo}/${inv_dir}/hosts
grep ${box} ${inventory_file}

export ANSIBLE_STDOUT_CALLBACK=yaml

ansible-playbook \
    -vv \
    ansible/site.yml \
    video-stack-bin-chicken/site.yml \
    --inventory-file ${inventory_file} \
    --limit $box \
    --user root \
    --diff \
    --vault-password-file ~/.ansible-vault \
    --extra-vars="{ \
'veyepar_confs': '/home/carl/src/veyepar', \
'veyepar_assets': '/home/carl/Videos/veyepar', \
'veyepar_url': 'http://veyepar.nextdayvideo.com', \
'user_password': 'useme', \
'vault_pw': '',  \
'ansible_python_interpreter': '/usr/bin/python3'}" \
    $3 $4

exit

    # --vault-password-file vault-sec.txt \
ansible-playbook \
    -vv \
    ansible/site.yml \
    --inventory-file ${inventory_file} \
    --limit $box \
    --user root \
    $3 $4

exit


    # --limit @/home/carl/src/tv/lca/ansible/site.retry \
    # --become-user videoteam --become --ask-become-pass \
    # --start-at-task="rnd : git clone bunch of things"

    # --check \

    #    lca2017-av/site.yml \

    # --extra-vars="{'xilinx_lic':'/home/carl/src/tv/Xilinx.lic'}" \
    # --extra-vars="{'veyepar_confs': '/home/carl/src/veyepar'}" \

    # --limit @/home/carl/src/tv/lca/ansible/site.retry \

    # --start-at-task="veyepar-secrets : copy local secret files" \
    # --start-at-task="configure voctomix"
    # --start-at-task='inject preseed into menu (find files)' \
    # --start-at-task="rnd : Create .Xilinx dir" \
    # --start-at-task="disable-screensaver : update settings to dconf"

    # --tags dome
    # --step "write jessie/preseed.cfg"
    # --step "motd"
    # --list-tasks


