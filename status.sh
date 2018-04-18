#!/bin/bash

#return code 0 = running
#return code 1 = finished successfully
#return code 2 = failed
#return code 3 = unknown (retry later)

if [ ! -f jobid.best ];then
	echo "no jobid.best - not yet submitted?"
	exit 3
fi

jobid_fit=`cat jobid.fit`
if [ -z $jobid_fit ]; then
	echo "jobid.fit is empty.. failed to submit?"
	exit 3
fi

jobid_best=`cat jobid.best`
if [ -z $jobid_best ]; then
	echo "jobid.best is empty.. failed to submit?"
	exit 3
fi

#collect info
fit_status=$(scontrol show job $jobid_fit | grep JobState)
find_best_status=$(scontrol show job $jobid_best | grep JobState)
running_count=$(grep RUNNING jobstate | wc -l)
#pending_count=$(grep PENDING jobstate | wc -l)
#completed_count=$(grep FAILED jobstate | wc -l)
completed_count=$(ls results*.mat 2>/dev/null | wc -l || true)
failed_count=$(grep FAILED jobstate | wc -l)
params=$(wc -l params.list)
true > jobstate
echo $fit_status >> jobstate
echo $find_best_status >> jobstate

#did it fail?
if [ $failed_count != "0" ]; then
	#if there is any job that's failed, mark as failed (TODO.. too strict?)
	./stop.sh
    echo "one of the jobs failed"
	exit 2
fi
 
#did it finish?
scontrol show job $jobid_best | grep "COMPLETED"
if [ $? -eq 0 ]; then
    echo "finished!"
    exit 1
fi

#was it canceled?
scontrol show job $jobid_best | grep "CANCELLED"
if [ $? -eq 0 ]; then
    echo "someone canceled!"
    exit 2
fi

#is fit running?
scontrol show job $jobid_fit | grep "RUNNING"
if [ $? -eq 0 ]; then
    echo "fitting .. $params running:$running_count completed:$completed_count"
    exit 0
fi

#is best running?
scontrol show job $jobid_best | grep "RUNNING"
if [ $? -eq 0 ]; then
    echo "finding best - creating final fe"
    exit 0
fi

echo "can't figure out what's going on.."
exit 3


