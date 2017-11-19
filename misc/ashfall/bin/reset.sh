#! /bin/bash

killall tes3mp-server
cd ~/
unison reset_world
unison reset_cells
rm ~/0.6.1-server/keepers/Data/MaintenanceMode/maintenance.lock
echo Done.
echo Please restart your server now.
