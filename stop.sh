#!/bin/bash

command=$(jq -r .command config.json)
if [ $command == "dp" ]; then
    ./stop_dp.sh
else
    stop
fi
