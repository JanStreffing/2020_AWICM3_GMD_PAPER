#!/bin/bash
ipath="/p/largedata/hhb19/jstreffi/runtime/awicm-3.1/"
exp="SPIN"
for var in SSR STR SLHF SSHF TTR TSR; do
	printf "$var | "
	for run in {1..25}; do
		printf "$run | "
		#printf "cdo yearmean $ipath/$exp/outdata/oifs/links/${var}_$(printf "%05d" $run).nc $ipath/zenodo/$exp/${var}_$(printf "%05d" $run).nc"
		cdo yearmean $ipath/$exp/outdata/oifs/links/${var}_$(printf "%05d" $run).nc $ipath/zenodo/$exp/${var}_$(printf "%05d" $run).nc &
	done
	for run in {34..45}; do
		printf "$run | "
		#printf "cdo yearmean $ipath/$exp/outdata/oifs/links/${var}_$(printf "%05d" $run).nc $ipath/zenodo/$exp/${var}_$(printf "%05d" $run).nc"
		cdo yearmean $ipath/$exp/outdata/oifs/links/${var}_$(printf "%05d" $run).nc $ipath/zenodo/$exp/${var}_$(printf "%05d" $run).nc &
	done
	wait
done
