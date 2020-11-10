#!/bin/ksh
#SBATCH --job-name=OPP
#SBATCH -p shared
#SBATCH --time=08:00:00
#SBATCH -A ab0246



start=$1
end=$2
exp=$3
var=$4
dir=$5

mkdir $dir/$exp/outdata/prep_for_vertical_plot/
cd $dir/$exp/outdata/prep_for_vertical_plot/
pwd

for i in {$1..$2}
do
        echo "   ====================================================="
        echo "   Yearmean for: exp $exp; var $var; year $i"
        echo "   ====================================================="
	cdo yearmean $dir/$exp/outdata/fesom/$var.fesom.$i.nc $var.fesom.$i.yearmean.nc
	file_name_string+="$var.fesom.$i.yearmean.nc"
done




