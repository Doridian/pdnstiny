#!/bin/sh
set -e

rm -rf /var/run/s6-services
mkdir -p /var/run/s6-services

found_service=0
for svc in /etc/s6/*; do
    if [ -f "$svc/should_run" ]; then
        if ! "$svc/should_run"; then
            echo "SKIPPING service $svc"
            continue
        fi
    fi
    echo "ENABLING service $svc"
    ln -s "$svc" /var/run/s6-services/
    found_service=1
done

if [ $found_service -eq 0 ]; then
    echo 'No services found to enable. Exiting.'
    exit 1
fi

exec s6-svscan /var/run/s6-services
