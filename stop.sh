#!/bin/bash

command=$(jq -r .command config.json)
if [ $command -eq "dp" ]; then
    ./stop_dp.sh
else
    stop
fi
