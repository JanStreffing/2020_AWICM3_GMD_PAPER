#!/bin/bash
ipath="/p/largedata/hhb19/jstreffi/runtime/awicm-3.1/"
exp="HIST"
for year in {1850..2014}; do
	printf "\n\n Processing $year \n"
	for var in a_ice m_ice sst temp w MLD2 ; do
	printf "$var | "
		#printf "cdo yearmean $ipath/$exp/outdata/fesom/$var.fesom.$year.nc $ipath/zenodo/$exp/$var.fesom.$year.nc &"
		cdo yearmean $ipath/$exp/outdata/fesom/$var.fesom.$year.nc $ipath/zenodo/$exp/$var.fesom.$year.nc &
	done
	wait
done
