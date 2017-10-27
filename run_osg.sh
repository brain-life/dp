#!/bin/bash
source /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/current/init/bash
module load matlab/2016b
env
./Process_batch_data 1 8 2.0 0.6
