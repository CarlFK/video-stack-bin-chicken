#!/bin/bash -ex

key=$1
location="rtmp://a.rtmp.youtube.com/live2/x/${key}"
# youtube says: rtmp://a.rtmp.youtube.com/live2

gst-launch-1.0 \
    decklinkvideosrc device-number=0 connection=HDMI mode=720p5994 \
    ! videoconvert ! deinterlace ! videorate ! videoscale \
    ! "video/x-raw,width=1280,height=720,framerate=30/1,pixel-aspect-ratio=1/1,colorimetry=bt709" \
    ! vaapih264enc keyframe-period=5 max-bframes=0 bitrate=2400 aud=true \
    ! "video/x-h264,profile=main" \
    ! h264parse config-interval=2 \
    ! mux. \
    decklinkaudiosrc device-number=0 connection=embedded \
    ! audioconvert ! audioresample ! audiorate \
    ! "audio/x-raw,format=S16LE,channels=2,layout=interleaved,rate=48000" \
    ! voaacenc bitrate=128000 \
    ! queue \
    ! flvmux streamable=true name=mux \
    ! rtmpsink location="${location} live=1"

