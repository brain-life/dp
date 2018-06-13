#!/bin/bash

command=$(jq -r .command config.json)
if [ $command -eq "dp" ]; then
    ./start_dp.sh
else
    start
fi
