#!/bin/bash

# These commands need to be ran as root

# Make sure kernel parameters are set high enough
if [ $(cat /proc/sys/kernel/msgmax) -lt 1048700 ]; then
    echo "msgmax is smaller than recommended"
    su -c 'echo "kernel.msgmax = 1048700" >> /etc/sysctl.conf'
fi

if [ $(cat /proc/sys/kernel/msgmnb) -lt 65536000 ]; then
    echo "msgmnb is smaller than recommended"
    su -c 'echo "kernel.msgmnb = 65536000" >> /etc/sysctl.conf'
fi

if [ $(cat /proc/sys/kernel/msgmni) -lt 512 ]; then
    echo "msgmni is smaller than recommended"
    su -c 'echo "kernel.msgmni = 512" >> /etc/sysctl.conf'
fi

# Activate any sysctl parameters
sysctl -p
