#!/bin/sh -Ceu

export DISPLAY=:1

nohup Xvfb $DISPLAY -ac -screen 0 1280x1024x8 -nolisten inet6 &
sleep 1

xvfb-run java -jar /opt/selenium/selenium-server-standalone.jar -debug true
