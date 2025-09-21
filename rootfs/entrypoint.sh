#!/bin/sh
set -e

exec s6-svscan /etc/s6
