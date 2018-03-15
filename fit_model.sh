#!/bin/bash
#PBS -N diff_pred-fit_model
#PBS -l nodes=1,walltime=03:00:00
#PBS -t [0-9]
#PBS -V

#pull nth param sets using $SLURM_ARRAY_TASK_ID
params=$(head -${SLURM_ARRAY_TASK_ID} params.list | tail -1)
alpha_v=$(echo $params | cut -f1 -d" ")
alpha_f=$(echo $params | cut -f2 -d" ")
lambda_1=$(echo $params | cut -f3 -d" ")
lambda_2=$(echo $params | cut -f4 -d" ")

echo "SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID running fit_model($alpha_v, $alpha_f, $lambda_1, $lambda_2)"
matlab -nodisplay -nosplash -r "fit_model($alpha_v, $alpha_f, $lambda_1, $lambda_2); exit"
#./compiled/fit_model $alpha_v $alpha_f $lambda_1 $lambda_2
