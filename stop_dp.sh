#!/bin/bash

if hash scancel 2>/dev/null; then
    scancel `cat jobid.fit`
    scancel `cat jobid.best`
fi

if hash qdel 2>/dev/null; then
    qdel `cat jobid.fit` #note.. might take a while for all jobs to be terminated
    qdel `cat jobid.best`

    #best job gets stuck on H state ... I need to run it again.. why!?
    sleep 10
    qdel `cat jobid.best`
fi
