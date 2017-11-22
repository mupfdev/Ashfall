#! /bin/bash

day=`date --date='-1 day' +'%Y-%m-%d'`

mkdir ~/backups/player/${day}
mv ~/backups/player/${day}_* ~/backups/player/${day}/

mkdir ~/backups/art/${day}
mv ~/backups/art/${day}_* ~/backups/art/${day}/

find ~/0.6.1-server/keepers/CoreScripts/data/player \
	 -maxdepth 1 -mtime +7 -exec \
	 mv -b {} ~/backups/disabled_accounts/ \;
