using the simple/stable usb_install scripts and preseed files
but different ansible playbook/inventory

```
  # /etc/nginx/sites-enabled/veyepar.nextdayvideo.com-http.conf

  location /scripts/ {
    alias /srv/www/scripts/;
    autoindex on;
  }
```

```
wget https://github.com/CarlFK/video-stack-bin-chicken/raw/master/scripts/setup/lc2/setup_lc2.sh
bash setup_lc2.sh
```

```
# usbinst/configs/pyohio24.cfg

more_appends="lc2_url=http://veyepar.NextDayVideo.com/scripts/late_command2.sh time/zone=US/Eastern"
```
