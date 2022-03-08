#!/bin/bash
ipath="/p/largedata/hhb19/jstreffi/runtime/awicm-3.1/"
exp="SPIN"
for year in {1850..2549}; do
	printf "\n\n Processing $year \n"
	for var in a_ice m_ice temp; do
	printf "$var | "
		cdo yearmean $ipath/$exp/outdata/fesom/$var.fesom.$year.nc $ipath/zenodo/$exp/$var.fesom.$year.nc &
	done
	wait
done
