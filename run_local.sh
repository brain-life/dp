#!/bin/bash

module load matlab/2017a

batch=100

#echo "splitting data to $batch batches"
#mkdir input
#matlab -nodisplay -nosplash -r "Prepare_batch_data_HCP3T_105115($batch)"

#echo "compile the Process_batch_data"
#matlab -nosplash -nodisplay -r compile.m

echo "transfer input files to csiu"
#scp -r input/* csiu.grid.iu.edu:/local-scratch/$USER/diffusion_predictor
scp -r bin csiu.grid.iu.edu:/local-scratch/$USER/diffusion_predictor/bin
scp run_osg.sh csiu.grid.iu.edu:/local-scratch/$USER/diffusion_predictor
ssh csiu.grid.iu.edu -C "mkdir -p /local-scratch/$USER/diffusion_predictor/log"

#echo "osg_submit on csiu"
#echo "TODO..."

#./bin/Process_batch_data 1 2 3 4.0
