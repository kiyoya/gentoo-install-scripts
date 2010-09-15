#!/bin/bash

## Installing Necessary System Tools

emerge syslog-ng --quiet
rc-update add syslog-ng default

emerge vixie-cron --quiet
rc-update add vixie-cron default

emerge logrotate --quiet
