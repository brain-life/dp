#!/bin/bash

command=$(jq -r .command config.json)
if [ $command == "dp" ]; then
    ./start_dp.sh
else
    start
fi
