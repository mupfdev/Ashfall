#! /bin/bash

today=`date '+%Y-%m-%d_%H:%M:%S'`

unison backup_player
mkdir "/home/tes3mp/backups/player/$today"
rsync -aSP "/home/tes3mp/backups/player/current/" "/home/tes3mp/backups/player/$today"
