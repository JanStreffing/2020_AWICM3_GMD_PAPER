#!/bin/bash
ipath="/p/largedata/hhb19/jstreffi/runtime/awicm-3.1/"
exp="4XCO"
for var in TTR TSR T2M; do
	printf "$var | "
	for run in {1..6}; do
		printf "$run | "
		#printf "cdo yearmean $ipath/$exp/outdata/oifs/links/${var}_$(printf "%05d" $run).nc $ipath/zenodo/$exp/${var}_$(printf "%05d" $run).nc"
		cdo yearmean $ipath/$exp/outdata/oifs/links/${var}_$(printf "%05d" $run).nc $ipath/zenodo/$exp/${var}_$(printf "%05d" $run).nc &
	done
	wait
done
