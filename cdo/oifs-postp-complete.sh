#!/usr/bin/ksh
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

# Example 1 : nohup ./oifs-postp-complete.sh /p/scratch/chhb19/jstreffi/runtime/awicm-3.1/POST/outdata/oifs/00001 00001 do_remove_raw &
# Example 2 : sbatch oifs-postp-complete.sh /p/scratch/chhb19/jstreffi/runtime/awicm-3.1/POST/outdata/oifs/00001 00001 do_remove_raw


cd ${TOPLEVEL}/
rm -f *0000000000* &
wait

echo "Concatenating OIFS output files"
pwd
ls *

for GRID in SH GG UA
do
	cat ICM${GRID}* > ICM${GRID}CAT &
done
wait

for GRID in SH GG UA
do
	if [[ "x$GRID" == "xGG" ]]; then
		cdo -f nc -t ecmwf copy -setgridtype,regular ICM${GRID}CAT ICMPP${GRID}$(printf "%05d" ${RUN_NUMBER_oifs}).nc &
	elif [[ "x$GRID" == "xSH" ]]; then
		cdo -f nc -t ecmwf copy -setgridtype,regular -sp2gpl ICM${GRID}CAT ICMPP${GRID}$(printf "%05d" ${RUN_NUMBER_oifs}).nc &
	elif [[ "x$GRID" == "xUA" ]]; then
		cdo -f nc -t ecmwf copy -setgridtype,regular ICM${GRID}CAT ICMPP${GRID}$(printf "%05d" ${RUN_NUMBER_oifs}).nc &
	fi
done
wait


for GRID in GG
do
		# We save precipitation and temperature at native resolution and timestep -> extreme event detection
		cdo -f nc -t ecmwf copy -setgridtype,regular -selvar,T2M,LSP,CP ICM${GRID}CAT temp${GRID}.nc
		cdo splitname temp${GRID}.nc remove_me_
		for filename in remove_me_*; do
			 [ -f "$filename" ] || continue
			first=${filename#"remove_me_"}
			last=${first%*.nc*}
			mv ${filename} ${last}_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
		done
		cdo chname,LSP,CP LSP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc LSPCP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
		cdo add LSPCP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc CP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc ADD_PRECIP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
		cdo chname,CP,PRECIP ADD_PRECIP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc HR_PRECIP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
		mv T2M_$(printf "%05d" ${RUN_NUMBER_oifs}).nc HR_T2M_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
		rm temp${GRID}.nc LSPCP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc CP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc ADD_PRECIP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc LSP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
done

for GRID in SH GG UA
do
	echo "Calculating mean values for OIFS output"
	cdo monmean ICMPP${GRID}$(printf "%05d" ${RUN_NUMBER_oifs}).nc ICMPP${GRID}$(printf "%05d" ${RUN_NUMBER_oifs})_monmean.nc &

done
wait

if [[ "x$EKE_oifs" == "xTRUE" ]];then
	echo "Calculating Mean and Eddy Kinetic Energy"
	cd ${TOPLEVEL}/outdata/oifs/$(printf "%05d" ${RUN_NUMBER_oifs})/
	cdo sellevel,25000 -selvar,U ICMPPSH$(printf "%05d" ${RUN_NUMBER_oifs}).nc u250_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
	cdo sellevel,25000 -selvar,V ICMPPSH$(printf "%05d" ${RUN_NUMBER_oifs}).nc v250_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
	cdo -chname,U,EKE -sqr u250_$(printf "%05d" ${RUN_NUMBER_oifs}).nc u2_for_eke
	cdo -chname,V,EKE -sqr v250_$(printf "%05d" ${RUN_NUMBER_oifs}).nc v2_for_eke
	cdo -chname,U,EKE -sqr -timmean u250_$(printf "%05d" ${RUN_NUMBER_oifs}).nc u2_bar_for_eke
	cdo -chname,V,EKE -sqr -timmean v250_$(printf "%05d" ${RUN_NUMBER_oifs}).nc v2_bar_for_eke
	cdo add u2_for_eke v2_for_eke u2v2_for_eke
	cdo add u2_bar_for_eke v2_bar_for_eke u2v2_bar_for_eke
	cdo divc,2 u2v2_for_eke u2v2_div_for_eke
	cdo divc,2 u2v2_bar_for_eke u2v2_bar_div_for_eke
	cdo sub u2v2_div_for_eke u2v2_bar_div_for_eke eke_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
	cdo -chname,EKE,EKEdivMKE -div eke_$(printf "%05d" ${RUN_NUMBER_oifs}).nc u2v2_bar_div_for_eke eke_to_mke_ratio_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
	cdo chname,EKE,MKE u2v2_bar_div_for_eke mke_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
	rm *for_eke
fi
if [[ "x$EPFLUX_oifs" == "xTRUE" ]];then
	echo "Calculating Eliassen-Palm Flux"
	cdo -sellevel,100000,70000,50000,40000,30000,20000,15000,10000,7000,5000,3000,2000,1000 -selvar,U ICMPPSH$(printf "%05d" ${RUN_NUMBER_oifs}).nc u_for_ep
	cdo -sellevel,100000,70000,50000,40000,30000,20000,15000,10000,7000,5000,3000,2000,1000 -selvar,V ICMPPSH$(printf "%05d" ${RUN_NUMBER_oifs}).nc v_for_ep
	cdo -sellevel,100000,70000,50000,40000,30000,20000,15000,10000,7000,5000,3000,2000,1000 -selvar,PT ICMPPSH$(printf "%05d" ${RUN_NUMBER_oifs}).nc pt_for_ep

	n_ep=0
	while true
	do
		START_DATE_ncl=`${FUNCTION_PATH}/calc_date plus -c1 -M${n_ep} -- ${START_DATE_oifs}`
		END_DATE_ncl=`${FUNCTION_PATH}/calc_date plus -c1 -M1 -- ${START_DATE_ncl}`
		END_DATE_ncl=`${FUNCTION_PATH}/calc_date minus -c1 -D1 -- ${END_DATE_ncl}`
		n_ep=$(($n_ep+1))
		echo " Start date for ncl script: ${START_DATE_ncl} "
		echo " End date for ncl script: ${END_DATE_ncl} "

		ncl ${TOPLEVEL}/scripts/esm-tools/esm-runscripts/functions/externals/ncl/epflux.ncl yearStrt=${START_DATE_ncl:0:4} monStrt=${START_DATE_ncl:4:2} dayStrt=${START_DATE_ncl:6:2} yearLast=${END_DATE_ncl:0:4} monLast=${END_DATE_ncl:4:2} dayLast=${END_DATE_ncl:6:2}
		cdo -r settaxis,${START_DATE_ncl:0:4}-${START_DATE_ncl:4:2}-${START_DATE_ncl:6:2},00:00:00,6hour epf.nc epf_step.nc             # cdo settaxis done twice
		cdo -r settaxis,${START_DATE_ncl:0:4}-${START_DATE_ncl:4:2}-${START_DATE_ncl:6:2},00:00:00,6hour epf_step.nc epf_t${n_ep}.nc	# otherwise it doesn't work...
		if [[ `${FUNCTION_PATH}/later_date -- ${END_DATE_ncl} ${END_DATE_oifs}` = ${END_DATE_ncl} ]]; then; break; fi
	done
	rm *for_ep epf_step.nc epf.nc
	cdo mergetime epf_t*.nc epf_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
	rm epf_t*
fi

echo "Extracting variables from monthly mean files"
cdo splitname ICMPPGG$(printf "%05d" ${RUN_NUMBER_oifs})_monmean.nc remove_me_ &
cdo splitname ICMPPSH$(printf "%05d" ${RUN_NUMBER_oifs})_monmean.nc remove_me_ &
cdo splitname ICMPPUA$(printf "%05d" ${RUN_NUMBER_oifs})_monmean.nc remove_me_ &
wait

for filename in remove_me_*; do
	 [ -f "$filename" ] || continue
	first=${filename#"remove_me_"}
	last=${first%*.nc*}
	mv ${filename} ${last}_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
done

if [[ "x$sixh_3D_out_oifs" == "xTRUE" ]];then
	cdo splitname ICMPPSH$(printf "%05d" ${RUN_NUMBER_oifs}).nc 6h_remove_me_
	for filename in 6h_remove_me_*; do
		 [ -f "$filename" ] || continue
		first=${filename#"6h_remove_me_"}
		last=${first%*.nc*}
		mv ${filename} 6h_${last}_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
	done
fi

cdo chname,LSP,CP LSP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc temporary_LSP.nc
cdo add temporary_LSP.nc CP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc temporary_PRECIP.nc
cdo chname,CP,PRECIP temporary_PRECIP.nc PRECIP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
cdo selvar,T2M ICMPPGG$(printf "%05d" ${RUN_NUMBER_oifs}).nc T2M_$(printf "%05d" ${RUN_NUMBER_oifs}).nc
cdo selvar,MSL ICMPPGG$(printf "%05d" ${RUN_NUMBER_oifs}).nc MSL_$(printf "%05d" ${RUN_NUMBER_oifs}).nc

if [[ "x$REMOVE_OUTPUT" == "xdo_remove_raw"]];then
	rm ICM* temporary*
fi

echo "Linking OIFS output files into single folder"
cd ${TOPLEVEL}
mkdir -p ../links
cd ${TOPLEVEL}/../links
ln -s ../$(printf "%05d" ${RUN_NUMBER_oifs})/*$(printf "%05d" ${RUN_NUMBER_oifs}).nc .

