#!/bin/bash
#SBATCH --account=hhb19
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1 
#SBATCH --job-name=pfix
#SBATCH --output=mpi-out.%j
#SBATCH --error=mpi-out.%j
#SBATCH --time=08:00:00
#SBATCH --partition=batch

#Usage:
# sbatch --export=TOPLEVEL='/p/scratch/chhb19/jstreffi/runtime/oifsamip/T1279/Experiment_11/E001/',RUN_NUMBER_oifs=00000,RES_oifs='TL1279',OIFS_PAMIP_PP=1 fix-oifs-postp.sh
# ./fix-oifs-postp.sh 
TOPLEVEL="/p/scratch/chhb19/jstreffi/runtime/awicm-3.1/PICT/outdata/oifs"

cd $TOPLEVEL
mkdir mistral_transfer
cd links
for VAR is 


