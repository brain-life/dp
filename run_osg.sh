#!/bin/bash
source /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/current/init/bash
module load matlab/2017a

hostname
date
ls -la

echo "running with arguments $@"
./Process_batch_data $@
