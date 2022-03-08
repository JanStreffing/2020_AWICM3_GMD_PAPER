#!/bin/bash
ipath="/p/largedata/hhb19/jstreffi/runtime/awicm-3.1/"
exp="HIST"
for var in T2M PRECIP TCC CI TTR CP LSP U10M V10M U V Z SSR STR SSRD; do
	printf "$var | "
	for run in {1..9}; do
		printf "$run | "
		if [ "$var" = "U" ] || [ "$var" = "U" ]; then
			cdo yearmean -sellevel,30000 $ipath/$exp/outdata/oifs/links/${var}_$(printf "%05d" $run).nc $ipath/zenodo/$exp/${var}_$(printf "%05d" $run).nc &
		elif [ "$var" = "Z" ]; then
			cdo yearmean -sellevel,50000 $ipath/$exp/outdata/oifs/links/${var}_$(printf "%05d" $run).nc $ipath/zenodo/$exp/${var}_$(printf "%05d" $run).nc &
		else
			cdo yearmean $ipath/$exp/outdata/oifs/links/${var}_$(printf "%05d" $run).nc $ipath/zenodo/$exp/${var}_$(printf "%05d" $run).nc &
		fi
	done
done
