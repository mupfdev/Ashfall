#! /bin/bash

LOG=`ls --format=single-column ~/backups/logs/current/ | sort -n -t _ -k 2 | tail -1`

tail -f ~/backups/logs/current/$LOG
