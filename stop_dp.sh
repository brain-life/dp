#!/bin/bash

if hash scancel 2>/dev/null; then
    scancel `cat jobid.fit`
    scancel `cat jobid.best`
fi

if hash qdel 2>/dev/null; then
    qdel `cat jobid.fit`
    qdel `cat jobid.best`

    #qdel somehow fails to stop jobs... 
    sleep 3
    qdel `cat jobid.fit`
    qdel `cat jobid.best`
    sleep 3
    qdel `cat jobid.fit`
    qdel `cat jobid.best`
fi
