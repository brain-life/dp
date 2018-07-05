#!/bin/bash
#PBS -N diff_pred-find_best
#PBS -l nodes=1:ppn=4,walltime=03:00:00
#PBS -V

#export PATH=.:$PATH
MAXMEM=32000000 singularity exec docker://brainlife/mcr:neurodebian1604-r2017a ./compiled/find_best
