
hn=$1
echo pw is odroid
ssh-copy-id root@$hn
scp hdmi2usb.hex root@$hn:/lib/firmware/
scp mk_c2b.sh root@$hn:
ssh root@$hn ./mk_c2b.sh
