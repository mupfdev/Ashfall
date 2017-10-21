#! /bin/bash

today=`date '+%Y-%m-%d_%H:%M:%S'`

unison backup_data
mkdir "/home/tes3mp/backups/data/$today"
rsync -aSP "/home/tes3mp/backups/data/current/" "/home/tes3mp/backups/data/$today"
