#!/bin/bash

if hash scancel 2>/dev/null; then
    scancel `cat jobid.fit`
    scancel `cat jobid.best`
fi

if hash qdel 2>/dev/null; then
    qdel `cat jobid.fit`
    sleep 3
    qdel `at jobid.best`
fi
