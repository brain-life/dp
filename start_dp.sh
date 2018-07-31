#!/bin/bash

set -e

rm -f jobid.fit
rm -f jobid.best
rm -f failed

a_min=$(jq -r .a_min config.json)
a_max=$(jq -r .a_max config.json)
a_step=$(jq -n "($a_max-$a_min)/6")

l1_min=$(jq -r .l1_min config.json)
l1_max=$(jq -r .l1_max config.json)
l1_step=$(jq -n "($l1_max-$l1_min)/6")

l2_min=$(jq -r .l2_min config.json)
l2_max=$(jq -r .l2_max config.json)
l2_step=$(jq -n "($l2_max-$l2_min)/6")

echo "generating parameter list"
true > params.list
for alpha_v in `seq -f '%g' $a_min $a_step $a_max`; do
    alpha_f=0
    for lambda_1 in `seq -f '%g' $l1_min $l1_step $l1_max`; do
        for lambda_2 in `seq -f '%g' $l2_min $l2_step $l2_max`; do
            echo $alpha_v $alpha_f $lambda_1 $lambda_2 >> params.list
        done
    done
done
echo "number of params $(wc -l params.list)"

#TODO - I need to remove output generated for parameter set that's not in params.list or profile app will break

#archive old logs
if [ -d logs ]; then
    mv logs logs.$(date +%F).$RANDOM
fi

#create new logs
mkdir -p logs
mkdir -p results

params=$(cat params.list | wc -l)

#manner
if hash srun 2>/dev/null; then
    #if all fit_model.sh gets submitted exactly at the same time, it could cause sharp memory usage spike which 
    #leads to job failurer. let's submit job to sleep for a while so that each node will start fit_model in staggered 
    echo "submitting staggering jobs"
    for i in `seq 1 20`;
    do
        time=$(($i%4 * 300))
        srun -J "stagger $i.$time" -c 8 sleep $time &
    done

    echo "submitting fit_model array(1-$params)"
    #TODO -c 8 shoudn't be needed as it's set on the script
    fit=$(sbatch --parsable -c 8  --array=1-$params -o "logs/slurm-%j.log" -e "logs/slurm-%j.err" fit_model.sh)
    echo $fit > jobid.fit

    echo "submitting find_best"
    #TODO -c 16 shoudn't be needed as it's set on the script
    best=$(sbatch --parsable -c 16 --dependency=afterok:$fit -o "logs/slurm-%j.log" -e "logs/slurm-%j.err" find_best.sh)
    echo $best > jobid.best
fi

if hash qsub 2>/dev/null; then
    echo "submitting fit_model array(1-$params)"
    fit=$(qsub -d $PWD -t 1-$params -l nodes=1:ppn=8,vmem=80g,walltime=06:00:00 -o logs/fit.log -e logs/fit.err fit_model.sh)
    echo $fit > jobid.fit

    echo "submitting find_best"
    best=$(qsub -d $PWD -W depend=afterokarray:$fit -l nodes=1:ppn=8,vmem=80g,walltime=03:00:00 -o logs/best.log -e logs/best.err find_best.sh)
    echo $best > jobid.best
fi
