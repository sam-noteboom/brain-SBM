#!/bin/bash

if [ "$#" -eq 0 ] 
then
	echo "Usage: ${0##*/} prefix )"
	exit 2
fi

source config.cfg
PREFIX=$1
WORKDIR_gm=$DATADIR/melodic_gm
WORKDIR_wb=$DATADIR/melodic_wb


if [ ! -e ${WORKDIR_wb}/wb_to_template_merged.nii.gz ]
then
  mkdir -p ${WORKDIR_gm}
  mkdir -p ${WORKDIR_wb}
  fslmerge -t ${WORKDIR_gm}/gm_to_template_merged.nii.gz ${DATADIR}/${PREFIX}*/warp2template/pve1_to_template_2mm_jac_3mm.nii.gz
  fslmerge -t ${WORKDIR_wb}/wb_to_template_merged.nii.gz ${DATADIR}/${PREFIX}*/warp2template/wb_to_template_2mm_jac_3mm.nii.gz
fi

array=( gm wb )
for pve in "${array[@]}"
do
	if [ ! -e ${WORKDIR}_${pve}/filtered_func_data.ica ]
	then
		WORKDIR=$DATADIR/melodic_${pve}
		fslmaths ${WORKDIR}/${pve}_to_template_merged.nii.gz $WORKDIR/prefiltered_func_data -odt float
		fslmaths ${WORKDIR}/prefiltered_func_data -mul 11438.7551889 ${WORKDIR}/prefiltered_func_data_intnorm
		fslmaths ${WORKDIR}/prefiltered_func_data_intnorm ${WORKDIR}/filtered_func_data
		fslhd -x ${WORKDIR}/filtered_func_data | sed 's/  dt = .*/  dt = '3.0'/g' > ${WORKDIR}/tmpHeader
		fslcreatehd ${WORKDIR}/tmpHeader ${WORKDIR}/filtered_func_data
		rm ${WORKDIR}/tmpHeader
		fslmaths ${WORKDIR}/filtered_func_data -Tmean ${WORKDIR}/mean_func
		rm -rf ${WORKDIR}/prefiltered_func_data*

		# Run melodic 
		melodic -i ${WORKDIR}/filtered_func_data -o ${WORKDIR}/filtered_func_data.ica -v --nobet --bgthreshold=3 --tr=3.0 --report --guireport=${WORKDIR}/../report.html -d 10 --vn --mmthresh=0.5
	fi
done;