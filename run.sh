#!/bin/bash
env | grep OSG

source /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/current/init/bash
module load matlab/2017a
echo "running with arguments $@"
./Process_batch_data $@
