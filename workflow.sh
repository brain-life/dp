#!/bin/bash

module load matlab/2017a

#echo "compile the Process_batch_data"
#matlab -nosplash -nodisplay -r "compile; quit"

#echo "splitting data"
#rm -rf input
#mkdir -p input
#matlab -nodisplay -nosplash -r "Prepare_batch_data_HCP3T_105115(10); quit"

echo "transfer input files to csiu"
scp -r input/* csiu.grid.iu.edu:/local-scratch/$USER/diffusion_predictor
scp -r bin csiu.grid.iu.edu:/local-scratch/$USER/diffusion_predictor
scp run.sh csiu.grid.iu.edu:/local-scratch/$USER/diffusion_predictor
scp job.submit csiu.grid.iu.edu:/local-scratch/$USER/diffusion_predictor
scp submit.dag csiu.grid.iu.edu:/local-scratch/$USER/diffusion_predictor
ssh csiu.grid.iu.edu -C "mkdir -p /local-scratch/$USER/diffusion_predictor/log"

echo "osg_submit on csiu"
echo "TODO..."

