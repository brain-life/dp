#!/bin/bash

#clean up previous logs
#mkdir -p oldlogs
#mv slurm-* oldlogs

rm -f jobid.fit
rm -f jobid.best

a_min=$(jq -r .a_min config.json)
a_max=$(jq -r .a_max config.json)
a_step=$(echo "scale=3;($a_max-$a_min)/7" | bc)

l1_min=$(jq -r .l1_min config.json)
l1_max=$(jq -r .l1_max config.json)
l1_step=$(echo "scale=3;($l1_max-$l1_min)/7" | bc)

l2_min=$(jq -r .l2_min config.json)
l2_max=$(jq -r .l2_max config.json)
l2_step=$(echo "scale=3;($l2_max-$l2_min)/7" | bc)

echo "generating parameter list"
true > params.list
#for alpha_v in `seq -f '%g' 0 1.0 14.4`; do
#    alpha_f=0
#    for lambda_1 in `seq -f '%g' 1.0 0.5 5.0`; do
#        for lambda_2 in `seq -f '%g' 0 0.1 0.5`; do
#            echo $alpha_v $alpha_f $lambda_1 $lambda_2 >> params.list
#        done
#    done
#done
for alpha_v in `seq -f '%g' $a_min $a_step $a_max`; do
    alpha_f=0
    for lambda_1 in `seq -f '%g' $l1_min $l1_step $l1_max`; do
        for lambda_2 in `seq -f '%g' $l2_min $l2_step $l2_max`; do
            echo $alpha_v $alpha_f $lambda_1 $lambda_2 >> params.list
        done
    done
done
echo "number of params $(wc -l params.list)"

#archive old logs
if [ -d logs ]; then
    mv logs logs.$(date +%F)
fi

#create new logs
mkdir -p logs
mkdir -p results

#if all fit_model.sh gets submitted exactly at the same time, it could cause sharp memory usage spike which 
#leads to job failurer. let's submit job to sleep for a while so that each node will start fit_model in staggered 
#manner
echo "submitting staggering jobs"
for i in `seq 1 20`;
do
    time=$(($i%4 * 300))
    srun -J "stagger $i.$time" -c 8 sleep $time &
done

params=$(cat params.list | wc -l)
echo "submitting fit_model array(1-$params)"
fit=$(sbatch --parsable -c 8  --array=1-$params -o "logs/slurm-%j.log" -e "logs/slurm-%j.err" fit_model.sh)
echo $fit > jobid.fit

echo "submitting fint_best"
best=$(sbatch --parsable -c 16 --dependency=afterok:$fit -o "logs/slurm-%j.log" -e "logs/slurm-%j.err" find_best.sh)
echo $best > jobid.best



