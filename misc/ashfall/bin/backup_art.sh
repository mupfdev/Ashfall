#! /bin/bash

today=`date '+%Y-%m-%d_%H:%M:%S'`

cd ~/
mkdir ~/backups/art/${today}
rsync -aSP ~/0.6.1-server/keepers/CoreScripts/data/cell/2,\ -12.json ~/backups/art/${today}
