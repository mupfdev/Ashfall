#! /bin/bash

nc -z -w 0 -u -vvvv ashfall.de 54765
if [ ! $? -eq 0 ]; then
    rm /home/tes3mp/server/keepers/maintenance.lock
    /home/tes3mp/server/tes3mp-server.sh
fi
