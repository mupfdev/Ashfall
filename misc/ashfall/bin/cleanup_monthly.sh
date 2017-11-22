#! /bin/bash

month=`date --date='-1 month' +'%Y-%m'`

mkdir ~/backups/logs/${month}
mv ~/backups/logs/${month}*_* ~/backups/logs/${month}

find ~/backups/player/ -maxdepth 1 ! -name "*_*" ! -name current ! -name player -name "$month*" -exec mv {} ~/backups/player/${month} \;
mkdir ~/backups/player/${month}
