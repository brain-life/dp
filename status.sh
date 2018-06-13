#!/bin/bash

#return code 0 = running
#return code 1 = finished successfully
#return code 2 = failed
#return code 3 = unknown (retry later)

command=$(jq -r .command config.json)
if [ $command == "dp" ]; then
    ./status_dp.sh
else
    status
fi

