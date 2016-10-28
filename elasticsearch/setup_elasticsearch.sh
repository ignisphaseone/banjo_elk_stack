#!/bin/bash
if [[ ! $EUID -eq 0 ]]; then
    echo "--this script requires root beer (sudo), exiting..."
fi

dpkg -i elasticsearch*.deb
