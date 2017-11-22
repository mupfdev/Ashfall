#! /bin/bash

today=`date '+%Y-%m-%d_%H:%M:%S'`

mkdir ~/backups/logs/${today}
ls --format=single-column --sort time \
   ~/0.6.1-server/keepers/home/config/*.log > ~/bin/tmpFiles.txt

sed -i '1d' ~/bin/tmpFiles.txt
xargs -a ~/bin/tmpFiles.txt mv -t ~/backups/logs/${today}
rm ~/bin/tmpFiles.txt
