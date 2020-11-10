#!/bin/bash

dir='/p/largedata/hhb19/jstreffi/runtime/awicm-3.1/'

for exp in  'PIC3' #'HIST' '4CO2' '1PCT'
do
        if [ $exp == PIC3 ]; then
                start=1990
                end=2990
        elif [ $res == HIST ]; then
                start=1850
                end=2015
        elif [ $res == 4CO2 ]; then
                start=1850
                end=2000
        elif [ $res == 1PCT ]; then
                start=1850
                end=2000
        fi

	
	for var in salt temp
	do
		./prep_for_vertical_plot.sh $start $end $exp $var $dir &
	done

done


