#!/bin/bash
#$ -N generate_maps
#$ -cwd
#$ -o log
#$ -e log
#$ -P fraser.prjc
#$ -q short.qc
#$ -t 13-276

module unload R
module load R/3.5.1-foss-2018b

make r_date="$SGE_TASK_ID" map_only

