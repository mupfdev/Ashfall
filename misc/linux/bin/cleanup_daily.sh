#! /bin/bash

day=`date --date='-1 day' +'%Y-%m-%d'`

mkdir "/home/tes3mp/backups/player/$day"
mv "/home/tes3mp/backups/player/$day"_* "/home/tes3mp/backups/player/$day/"

find /home/tes3mp/server/keepers/server_data/data/player \
	 -maxdepth 1 -mtime +7 -exec \
	 mv -b '"{}"' /home/tes3mp/backups/disabled_accounts/ \;

find /home/tes3mp/server/keepers/server_data/data/player \
	 -maxdepth 1 -mtime +7 -exec \
	 sh -c 'rm /home/tes3mp/server/keepers/mailbox/$(basename "{}" | cut -d. -f1).txt' \;
