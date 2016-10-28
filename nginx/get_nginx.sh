#!/bin/bash
if [[ ! $EUID -eq 0 ]]; then
    echo "--this script requires root beer (sudo), exiting..."
fi

apt update
apt install nginx -y
