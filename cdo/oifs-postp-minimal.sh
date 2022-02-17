#!/bin/bash
#SBATCH --account=hhb19
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1 
#SBATCH --job-name=pfix
#SBATCH --output=mpi-out.%j
#SBATCH --error=mpi-out.%j
#SBATCH --time=08:00:00
#SBATCH --partition=esm


TOPLEVEL=$1             # Path to output folder
RUN_NUMBER_oifs=$2      # eg. 00001
REMOVE_OUTPUT=$3        # Logical switch if raw output shall be removed after processing

# Example 1 : nohup ./oifs-postp-minimal.sh /work/ollie/jstreffi/runtime/awicm3-v3.0/lead_alb_tuning_5/outdata/oifs/20091231 00001 do_remove_raw &
# Example 2 : sbatch oifs-postp-minimal.sh /work/ollie/jstreffi/runtime/awicm3-v3.0/lead_alb_tuning_5/outdata/oifs/20091231 00001 do_remove_raw

cd ${TOPLEVEL}/

echo "Concatenating OIFS output files"
pwd

for GRID in GG SH UA; do
        cdo mergetime ICM${GRID}* ICM${GRID}CAT &
done
wait

for GRID in GG SH UA; do
        cdo monmean ICM${GRID}CAT ICM${GRID}monmean &
done
wait

for GRID in GG SH UA; do
        if [[ "x$GRID" == "xGG" ]]; then
                cdo -f nc -t ecmwf copy -setgridtype,regular ICM${GRID}monmean ICMPP${GRID}$(printf "%05d" ${RUN_NUMBER_oifs}).nc &
        else
                cdo -f nc -t ecmwf copy -setgridtype,regular -sp2gpl ICM${GRID}monmean ICMPP${GRID}$(printf "%05d" ${RUN_NUMBER_oifs}).nc &
        fi
done
wait

if [[ "x$REMOVE_OUTPUT" == "xdo_remove_raw"]];then
        echo "Removing raw OIFS output"
	for GRID in GG SH UA; do
        	rm -f ICM${GRID}* ICM${GRID}CAT ICM${GRID}monmean &
	done
fi
