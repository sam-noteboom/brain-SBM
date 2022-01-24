#!/bin/bash

if [ "$#" -eq 0 ] 
then
	echo "Usage: ${0##*/} prefix )"
	exit 2
fi

source config.cfg
PREFIX=$1

# Define group template and MNI 2 mm template
template=${TEMPDIR}/T_template0.nii.gz
mni2mm=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz

# Define data directories
for DIR in ${DATADIR}/${PREFIX}*
do
	SUBJID=${DIR##*/}
	SIENAXDIR=${DATADIR}/${SUBJID}/t1_sienax
	WORKDIR=${DATADIR}/${SUBJID}/warp2template

	if [ -e ${WORKDIR} ] # Check if subjid is already (being) processed
	then
		continue 
	else
		mkdir -p ${WORKDIR}
	fi

	# Define subject t1 brain
	t1_brain=${SIENAXDIR}/I_brain.nii.gz

	# Warp I_brain to mni space
	antsRegistrationSyNQuick.sh -d 3 -f $template -m $t1_brain -o ${WORKDIR}/I_brain_to_mni -t s

	# Subject warp files
	warp=$WORKDIR/I_brain_to_mni1Warp.nii.gz
	affinemat=$WORKDIR/I_brain_to_mni0GenericAffine.mat

	# Calculate whole brain PVE and cp GM PVE
	if [ ! -e ${WORKDIR}/I_stdmaskbrain_pve_wb.nii.gz ] && [ -e ${SIENAXDIR}/I_stdmaskbrain_pve_1.nii.gz ] ; then
		echo "$SUBJID calculate pve_1+pve_2"
		fslmaths ${SIENAXDIR}/I_stdmaskbrain_pve_1.nii.gz -add ${SIENAXDIR}/I_stdmaskbrain_pve_2.nii.gz ${WORKDIR}/I_stdmaskbrain_pve_wb.nii.gz
		ln -s ${SIENAXDIR}/I_stdmaskbrain_pve_1.nii.gz ${WORKDIR}/I_stdmaskbrain_pve_1.nii.gz
	fi

	# PVE registration to group template
	if [ ! -e ${WORKDIR}/pve1_to_template_2mm.nii.gz ] ; then
		antsApplyTransforms -d 3 -i ${WORKDIR}/I_stdmaskbrain_pve_1.nii.gz -r $mni2mm -o ${WORKDIR}/pve1_to_template_2mm.nii.gz -n Linear -t ${warp} -t ${affinemat} --verbose
		antsApplyTransforms -d 3 -i ${WORKDIR}/I_stdmaskbrain_pve_wb.nii.gz -r $mni2mm -o ${WORKDIR}/wb_to_template_2mm.nii.gz -n Linear -t ${warp} -t ${affinemat} --verbose
	fi

	# Calculate Jacobian
	if [ ! -e ${WORKDIR}/I_brain_WarpJacobian.nii.gz ] ; then
		CreateJacobianDeterminantImage 3 ${warp} ${WORKDIR}/I_brain_WarpJacobian.nii.gz
	fi

	# Multiply pve by Jacobian and smooth with 3mm
	if [ ! -e ${WORKDIR}/wb_to_template_2mm_jac_3mm.nii.gz ] ; then

		# Gray matter pve map
		ImageMath 3 ${WORKDIR}/pve1_to_template_2mm_jac.nii.gz m ${WORKDIR}/pve1_to_template_2mm.nii.gz ${WORKDIR}/I_brain_WarpJacobian.nii.gz
		ImageMath 3 ${WORKDIR}/pve1_to_template_2mm_jac_3mm.nii.gz G ${WORKDIR}/pve1_to_template_2mm_jac.nii.gz 3

		# Brain tissue pve map
		ImageMath 3 ${WORKDIR}/wb_to_template_2mm_jac.nii.gz m ${WORKDIR}/wb_to_template_2mm.nii.gz ${WORKDIR}/I_brain_WarpJacobian.nii.gz
		ImageMath 3 ${WORKDIR}/wb_to_template_2mm_jac_3mm.nii.gz G ${WORKDIR}/wb_to_template_2mm_jac.nii.gz 3
	fi
done;
