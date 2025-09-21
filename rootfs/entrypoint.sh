#!/bin/sh
set -e

cp -vdprn /etc/pdns-stock/* /etc/pdns

exec s6-svscan /etc/s6
