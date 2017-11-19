#! /bin/bash

nc -z -w 0 -u -vvvv ashfall.de 54765
if [ ! $? -eq 0 ]; then
    screen -S tes3mp -d -m zsh -c ~/0.6.1-server/run.sh
fi
