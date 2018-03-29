#!/bin/bash

#return code 0 = running
#return code 1 = finished successfully
#return code 2 = failed
#return code 3 = unknown (retry later)

if [ ! -f jobid.best ];then
	echo "no jobid.best - not yet submitted?"
	exit 1
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

true > jobstate
scontrol show job $jobid_fit | grep JobState >> jobstate
scontrol show job $jobid_best | grep JobState >> jobstate
running_count=$(grep RUNNING jobstate | wc -l)
pending_count=$(grep PENDING jobstate | wc -l)
failed_count=$(grep FAILED jobstate | wc -l)
completed_count=$(grep FAILED jobstate | wc -l)
echo "running:$running_count pending:$pending_count failed:$failed_count completed:$completed_count"

if [ $failed_count != "0" ]; then
	#if there is any job that's failed, mark as failed (TODO.. to strict?)
	./stop.sh
	exit 2
fi
