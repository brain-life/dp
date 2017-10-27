#!/bin/bash
source /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/current/init/bash
module load matlab/2016b
env > output.$RANDOM
#./Process_batch_data $@
