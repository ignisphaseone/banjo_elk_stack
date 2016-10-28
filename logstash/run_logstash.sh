#!/bin/bash
if [[ ! $EUID -eq 0 ]]; then
    echo "--this script requires root beer (sudo), exiting..."
fi

cd /opt/logstash/bin
./logstash agent -f logstash-banjo.conf
