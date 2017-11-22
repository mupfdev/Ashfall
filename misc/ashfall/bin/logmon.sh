#! /bin/bash

LOG=`ls ~/backups/logs/current/ | awk -F_ '{print $1 $2}' | sort -n -k 2,2 | tail -1`

tail -f ~/backups/logs/current/$LOG
