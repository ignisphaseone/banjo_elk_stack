#!/bin/bash
if [[ ! $EUID -eq 0 ]]; then
    echo "--this script requires root beer (sudo), exiting..."
fi

# Install the logstash deb you have.
dpkg -i logstash*.deb -y

# Copy the config file and template into place.
cp logstash-banjo.conf /opt/logstash/bin/
cp elasticstack-nginx-template.json /opt/logstash/bin/
