#!/bin/bash

if hash scancel 2>/dev/null; then
    scancel `cat jobid.fit`
    scancel `cat jobid.best`
fi

if hash qdel 2>/dev/null; then
    qdel `cat jobid.fit`
    qdel `cat jobid.best`

    #might take a while for all jobs to be terminated

fi
