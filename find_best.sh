#!/bin/bash
#PBS -N diff_pred-find_best
#PBS -l nodes=1,walltime=03:00:00
#PBS -V

matlab -nodisplay -r find_best
#./compiled/find_best
