#!/bin/bash
#SBATCH --account=hhb19
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1 
#SBATCH --job-name=pfix
#SBATCH --output=mpi-out.%j
#SBATCH --error=mpi-out.%j
#SBATCH --time=08:00:00
#SBATCH --partition=batch

#Usage:
# sbatch --export=TOPLEVEL='/p/scratch/chhb19/jstreffi/runtime/oifsamip/T1279/Experiment_11/E001/',RUN_NUMBER_oifs=00000,RES_oifs='TL1279',OIFS_PAMIP_PP=1 fix-oifs-postp.sh
# ./fix-oifs-postp.sh 
TOPLEVEL="/p/scratch/chhb19/jstreffi/runtime/awicm-3.1/PICT/outdata/oifs"

cd $TOPLEVEL

for (( RUN_NUMBER_oifs=16; RUN_NUMBER_oifs<17; RUN_NUMBER_oifs++ ));
do
	cd $(printf "%05d" ${RUN_NUMBER_oifs})
	pwd
	ncdump -h LSP_$(printf "%05d" ${RUN_NUMBER_oifs}).nc >>temp
	INPUT=$(awk 'NR==3' temp)
	rm temp
	SUBSTRING=$(echo $INPUT| cut -d'(' -f2 )
	LAST_TIME_STEP=$(echo $SUBSTRING| cut -d' ' -f1 )
	SECOND_LAST_TIME_STEP=$((LAST_TIME_STEP - 1))
	printf $SECOND_LAST_TIME_STEP

	for VAR in PRECIP PT R T U V VO v250 LNSP STRF CI ASN TCC LSM LCC MCC HCC FAL TVL CHNK FLSR CAPE SSTK ISTL1 ISTL2 ISTL3 ISTL4 STL1 D2M STL2 STL3 DHCC DHLC SKT STL4 TSN ATTE TCLW TCIW TCW TCWV TCO3 VIMD IE SRO SSRO LSP CP SF BLH RO TP FSR ES SMLT SD E SRC U10M V10M VDZW VDMW EWGD NSGD Z IEWS INSS EWSS NSSS LGWS MGWS LSPF DSRP TSRC TTRC SSRC STRC SI ISHF PARCS UVB PAR BLD SSHF SLHF SSRD STRD SSR STR TSR TTR GWD
	do
		printf $VAR
		if [[ -f "${VAR}_$(printf "%05d" ${RUN_NUMBER_oifs}).nc" ]]; then
			cdo seltimestep,1/$SECOND_LAST_TIME_STEP ${VAR}_$(printf "%05d" ${RUN_NUMBER_oifs}).nc ${VAR}_$(printf "%05d" ${RUN_NUMBER_oifs})_cut.nc &
		fi
	done
	wait

	for VAR in PRECIP PT R T U V VO v250 LNSP STRF CI ASN TCC LSM LCC MCC HCC FAL TVL CHNK FLSR CAPE SSTK ISTL1 ISTL2 ISTL3 ISTL4 STL1 D2M STL2 STL3 DHCC DHLC SKT STL4 TSN ATTE TCLW TCIW TCW TCWV TCO3 VIMD IE SRO SSRO LSP CP SF BLH RO TP FSR ES SMLT SD E SRC U10M V10M VDZW VDMW EWGD NSGD Z IEWS INSS EWSS NSSS LGWS MGWS LSPF DSRP TSRC TTRC SSRC STRC SI ISHF PARCS UVB PAR BLD SSHF SLHF SSRD STRD SSR STR TSR TTR GWD
        do      
                if [[ -f "${VAR}_$(printf "%05d" ${RUN_NUMBER_oifs}).nc" ]]; then
                	mv ${VAR}_$(printf "%05d" ${RUN_NUMBER_oifs})_cut.nc ${VAR}_$(printf "%05d" ${RUN_NUMBER_oifs}).nc &
		fi
        done
        wait
	cd ..
done
