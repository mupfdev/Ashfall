#!/bin/bash

file=/home/tes3mp/server/keepers/maintenance.lock

echo "Maintenance Mode"
if [ -f $file ]; then
    echo "Disabled."
    rm $file
else
  echo "Enabled."
  touch $file
fi
