#!/bin/bash
##PBS -N diff_pred-fit_model
##PBS -l nodes=1,ppn=8,vmem=16g,walltime=04:30:00
##PBS -V

echo "Running SLURM_ARRAY_TASK_ID:$SLURM_ARRAY_TASK_ID"

#pull nth param sets using $SLURM_ARRAY_TASK_ID
params=$(head -${SLURM_ARRAY_TASK_ID} params.list | tail -1)
alpha_v=$(echo $params | cut -f1 -d" ")
alpha_f=$(echo $params | cut -f2 -d" ")
lambda_1=$(echo $params | cut -f3 -d" ")
lambda_2=$(echo $params | cut -f4 -d" ")

#might prevent parpool initialization error
#https://github.com/UCL-RITS/rcps-buildscripts/issues/55#issuecomment-256309931
#IT doesn't seems to work, and I've read that MATLAB_PREFDIR gets baked into the compiled module(?)
#https://undocumentedmatlab.com/blog/removing-user-preferences-from-deployed-apps
#export MATLAB_PREFDIR=/tmp/$SLURM_JOB_ID/pref

echo "SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID running fit_model($alpha_v, $alpha_f, $lambda_1, $lambda_2)"
#matlab -nodisplay -nosplash -r "fit_model($alpha_v, $alpha_f, $lambda_1, $lambda_2); exit"

if [ -f "results_alpha_v_${alpha_v}_alpha_f_${alpha_f}_lambda_1_${lambda_1}_lambda_2_${lambda_2}.mat" ]; then
    echo "output file already exist.. skipping"
    exit 0
fi

echo "generating results_alpha_v_${alpha_v}_alpha_f_${alpha_f}_lambda_1_${lambda_1}_lambda_2_${lambda_2}.mat"
time singularity exec -e docker://brainlife/mcr:neurodebian1604-r2017a ./compiled/fit_model $alpha_v $alpha_f $lambda_1 $lambda_2
