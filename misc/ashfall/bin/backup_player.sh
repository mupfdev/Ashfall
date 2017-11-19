#! /bin/bash

today=`date '+%Y-%m-%d_%H:%M:%S'`

cd ~/
unison backup_player
mkdir ~/backups/player/${today}
rsync -aSP ~/backups/player/current/ ~/backups/player/${today}
