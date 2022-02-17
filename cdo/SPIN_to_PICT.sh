#!/bin/bash
ipath="/p/scratch/chhb19/jstreffi/runtime/awicm-3.1/SPIN/outdata/fesom"
opath="/p/scratch/chhb19/jstreffi/runtime/awicm-3.1/PICT/outdata/fesom"

for year in {1850..2014}; do
	printf "\n\n Processing $year \n"
	for var in a_ice cd fw MLD2 runoff sst thdgrsn alb ce ist momix_length subli tx_sur vice Av ch m_snow shum swr ty_sur vwind evap lwr snow tair fh m_ice prec ssh uice flice MLD1 sss thdgr uwind; do
		printf "$var | "
		cdo -L settaxis,$year-01-01,23:20,31day -setreftime,$year-01-01 $ipath/$var.fesom.$(($year+500)).nc $opath/$var.fesom.$year.nc &
	done
	for var in bolus_u bolus_v  bolus_w u v w temp salt Kv N2 Redi_K; do
		printf "$var | "
		cdo -L settaxis,$year-01-01,23:20,180day -setreftime,$year-01-01 $ipath/$var.fesom.$(($year+500)).nc $opath/$var.fesom.$year.nc &
	done
	wait
done
