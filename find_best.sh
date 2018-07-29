#!/bin/bash

MAXMEM=32000000 singularity exec docker://brainlife/mcr:neurodebian1604-r2017a ./compiled/find_best
