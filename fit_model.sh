#!/bin/bash

[ $PBS_ARRAYID ] && TASK_ID=$PBS_ARRAYID
[ $SLURM_ARRAY_TASK_ID ] && TASK_ID=$SLURM_ARRAY_TASK_ID

#pull nth param sets using $SLURM_ARRAY_TASK_ID
params=$(head -$TASK_ID params.list | tail -1)
echo "Running TASK_ID:$TASK_ID $params ...................."
alpha_v=$(echo $params | cut -f1 -d" ")
alpha_f=$(echo $params | cut -f2 -d" ")
lambda_1=$(echo $params | cut -f3 -d" ")
lambda_2=$(echo $params | cut -f4 -d" ")

#might prevent parpool initialization error
#https://github.com/UCL-RITS/rcps-buildscripts/issues/55#issuecomment-256309931
#IT doesn't seems to work, and I've read that MATLAB_PREFDIR gets baked into the compiled module(?)
#https://undocumentedmatlab.com/blog/removing-user-preferences-from-deployed-apps
#export MATLAB_PREFDIR=/tmp/$SLURM_JOB_ID/pref


echo "TASK_ID=$TASK_ID running fit_model($alpha_v, $alpha_f, $lambda_1, $lambda_2)"

outpath="results/alpha_v_${alpha_v}_alpha_f_${alpha_f}_lambda_1_${lambda_1}_lambda_2_${lambda_2}.mat"
if [ -f $outpath ]; then
    echo "output file already exist.. skipping"
    exit 0
fi

echo "generating $outpath"
for i in $(seq 1 5); 
do 
	echo "try $i"
	MAXMEM=16000000 singularity exec docker://brainlife/mcr:neurodebian1604-r2017a ./compiled/fit_model $alpha_v $alpha_f $lambda_1 $lambda_2 $outpath && break
	echo "failed.. may retry"
	sleep 15
done
