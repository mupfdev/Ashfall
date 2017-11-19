#!/bin/bash

file=~/0.6.1-server/keepers/Data/MaintenanceMode/maintenance.lock

echo "Maintenance Mode"
if [ -f $file ]; then
    echo "Disabled."
    rm $file
else
  echo "Enabled."
  touch $file
fi
