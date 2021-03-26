
hn=$1
echo pw is odroid
ssh-copy-id root@$hn
scp hdmi2usb.hex root@$hn:/lib/firmware/
scp mk_c2b.sh root@$hn:
scp videoteam-ingest root@$hn:/usr/local/bin/
scp videoteam-ingest.service root@$hn:/etc/systemd/system/
scp videoteam-ingest.path root@$hn:/etc/systemd/system/
ssh root@$hn ./mk_c2b.sh
