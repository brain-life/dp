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

#sbatch fit_model.sh
#else
#	echo "no sbatch.. guessing it's running on a test machine"
#	#simulate sbatch with one task ID
#	SLURM_ARRAY_TASK_ID=665 nohup ./fit_model.sh &
#fi


