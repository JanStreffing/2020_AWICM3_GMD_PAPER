#!/bin/bash
ipath="/p/largedata/hhb19/jstreffi/runtime/awicm-3.1/"
exp="PICT"
for var in T2M PRECIP; do
	printf "$var | "
	for run in {1..9}; do
		printf "$run | "
		#printf "cdo yearmean $ipath/$exp/outdata/oifs/links/${var}_$(printf "%05d" $run).nc $ipath/zenodo/$exp/${var}_$(printf "%05d" $run).nc"
		cdo yearmean $ipath/$exp/outdata/oifs/links/${var}_$(printf "%05d" $run).nc $ipath/zenodo/$exp/${var}_$(printf "%05d" $run).nc &
	done
done
