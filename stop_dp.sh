#!/bin/bash

if [ `which scancel` ]; then
    scancel `cat jobid.fit`
    scancel `cat jobid.best`
fi
if [ `which qdel` ]; then
    echo "qdel" 
    cat jobid.fit
    cat jobid.best
    qdel `cat jobid.fit`
    sleep 5
    qdel `cat jobid.best`
fi
