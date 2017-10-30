#! /bin/bash

month=`date --date='-1 month' +'%Y-%m'`

mkdir "/home/tes3mp/backups/data/$month"
mv "/home/tes3mp/backups/data/$month"*_* "/home/tes3mp/backups/data/$month"

mkdir "/home/tes3mp/backups/logs/$month"
mv "/home/tes3mp/backups/logs/$month"*_* "/home/tes3mp/backups/logs/$month"

find "/home/tes3mp/backups/player/" -maxdepth 1 ! -name "*_*" ! -name current ! -name player -name "$month*" -exec mv {} "/home/tes3mp/backups/player/$month" \;
mkdir "/home/tes3mp/backups/player/$month"
