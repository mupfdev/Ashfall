#! /bin/bash

today=`date '+%Y-%m-%d_%H:%M:%S'`

mkdir "/home/tes3mp/backups/logs/$today"
ls --format=single-column --sort time \
   /home/tes3mp/server/keepers/home/config/openmw/*.log > /home/tes3mp/bin/tmpFiles.txt

sed -i '1d' /home/tes3mp/bin/tmpFiles.txt
xargs -a /home/tes3mp/bin/tmpFiles.txt mv -t "/home/tes3mp/backups/logs/$today"
rm /home/tes3mp/bin/tmpFiles.txt
