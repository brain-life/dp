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

echo "SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID running fit_model($alpha_v, $alpha_f, $lambda_1, $lambda_2)"
#matlab -nodisplay -nosplash -r "fit_model($alpha_v, $alpha_f, $lambda_1, $lambda_2); exit"

echo "running singularity"
time singularity exec -e docker://brainlife/mcr:neurodebian1604-r2017a ./compiled/fit_model $alpha_v $alpha_f $lambda_1 $lambda_2
