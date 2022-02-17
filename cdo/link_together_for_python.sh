#!/bin/bash
# Links OpenIFS output files of base and branchoff experiment into single folder

# Example usage: 
# bash link_together_for_python.sh /p/scratch/chhb19/jstreffi/runtime/awicm-3.1/SPIN_drymassfixer/outdata/oifs/links /p/scratch/chhb19/jstreffi/runtime/awicm-3.1/MASS/outdata/oifs/links  /p/scratch/chhb19/jstreffi/runtime/awicm-3.1/MASS/outdata/oifs/links_combined_with_SPIN 2 2

BASE_DIR=$1		# Folder of base experiment
BRANCH_DIR=$2   	# Folder of branch experiment
TARGET_DIR=$3           # New folder with combined output
BASE_LEN=$4   		# How many legs long was the base run
BRANCH_LEN=$5		# How many legs long was the branch run

mkdir -p $TARGET_DIR

for VAR in PRECIP PT R T U V VO v250 LNSP STRF CI ASN TCC LSM LCC MCC HCC FAL TVL CHNK FLSR CAPE SSTK ISTL1 ISTL2 ISTL3 ISTL4 STL1 D2M STL2 STL3 DHCC DHLC SKT STL4 TSN ATTE TCLW TCIW TCW TCWV TCO3 VIMD IE SRO SSRO LSP CP SF BLH RO TP FSR ES SMLT SD E SRC U10M V10M VDZW VDMW EWGD NSGD Z IEWS INSS EWSS NSSS LGWS MGWS LSPF DSRP TSRC TTRC SSRC STRC SI ISHF PARCS UVB PAR BLD SSHF SLHF SSRD STRD SSR STR TSR TTR GWD
do
	for ((i = 1 ; i < $(($BASE_LEN+1)) ; i++)); do
		ln -s ${BASE_DIR}/${VAR}_$(printf "%05d" ${i}).nc ${TARGET_DIR}/${VAR}_$(printf "%05d" ${i}).nc
	done
	for ((i = $(($BASE_LEN+1)) ; i < $(($BASE_LEN+$BRANCH_LEN+1)) ; i++)); do
		ln -s ${BRANCH_DIR}/${VAR}_$(printf "%05d" $(($i-$BASE_LEN))).nc ${TARGET_DIR}/${VAR}_$(printf "%05d" ${i}).nc
	done
done
