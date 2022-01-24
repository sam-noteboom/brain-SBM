#!/bin/bash

if [ "$#" -eq 0 ] 
then
	echo "Usage: ${0##*/} prefix )"
	exit 2
fi

source config.cfg
PREFIX=$1
mni=${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz

for DIR in ${DATADIR}/${PREFIX}*
do
	SUBJID=${DIR##/*/}
	SIENAXDIR=${DIR}/t1_sienax
	WORKDIR=${DIR}/register2mni

	if [ ! -e ${WORKDIR} ]
	then
		# Register I_brain to mni template
		mkdir ${WORKDIR}
		echo "$SUBJID perform registration I_brain to mni"
		flirt -in ${SIENAXDIR}/I_brain.nii.gz -ref ${mni} -out ${WORKDIR}/I_brain_to_mni

		# Normalize image
		echo "$SUBJID normalize I_brain_mni"
		max=`fslstats ${WORKDIR}/I_brain_to_mni.nii.gz -P 95`
		fslmaths ${WORKDIR}/I_brain_to_mni.nii.gz -div $max ${WORKDIR}/I_brain_to_mni_norm
	fi
done;

# Merge all warps to MNI to create initial template
if [ ! -e ${TEMPDIR}/I_brain_to_mni_norm_merged.nii.gz ]
then
	mkdir -p ${TEMPDIR}
	fslmerge -t $TEMPDIR/I_brain_to_mni_norm_merged.nii.gz ${DATADIR}/${PREFIX}*/register2mni/I_brain_to_mni_norm.nii.gz 
	fslmaths ${TEMPDIR}/I_brain_to_mni_norm_merged.nii.gz -Tmean ${TEMPDIR}/I_brain_to_mni_norm_mean.nii.gz
fi