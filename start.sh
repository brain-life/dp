#!/bin/bash

echo "generating parameter list"
true > params.list
for alpha_v in `seq 0 0.4 7.2`; do
    alpha_f=0
    for lambda_1 in `seq 1.0 0.25 2.5`; do
        for lambda_2 in `seq 0 0.05 0.2`; do
            echo $alpha_v $alpha_f $lambda_1 $lambda_2 >> params.list
        done
    done
done

params=$(cat params.list | wc -l)
echo "submitting fit_model array(1-$params)"
fit=$(sbatch --parsable --array=1-$params -o "slurm-%j.log" -e "slurm-%j.err" fit_model.sh)
echo $fit > jobid.fit

echo "submitting fint_best"
best=$(sbatch --parsable --dependency=afterok:$fit -o "slurm-%j.log" -e "slurm-%j.err" find_best.sh)
echo $best > jobid.best

#else
#	echo "no sbatch.. guessing it's running on a test machine"
#	#simulate sbatch with one task ID
#	SLURM_ARRAY_TASK_ID=665 nohup ./fit_model.sh &
#fi


