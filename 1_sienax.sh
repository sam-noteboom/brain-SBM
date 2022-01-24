#!/bin/bash

if [ "$#" -eq 0 ] 
then
	echo "Usage: ${0##*/} prefix )"
	exit 2
fi

source config.cfg
PREFIX=$1

for DIR in ${DATADIR}/${PREFIX}*
do
	SUBJID=${DIR##/*/}
	T1PATH=${DIR}/${T1DIR}
	WORKDIR=${DIR}/t1_sienax
	echo "T1PATH=${T1PATH}" 
	echo "WORKDIR=${WORKDIR}"

	if [ -e ${T1PATH} ] && [  ! -e ${WORKDIR} ]
	then
		echo "Run SIENAx ${SUBJID}"
		mkdir -p $WORKDIR
		standard_space_roi ${T1PATH} ${WORKDIR}/t1_noneck -maskFOV -roiNONE
		sienax ${WORKDIR}/t1_noneck.nii.gz -o ${WORKDIR} -d -r -B "-f 0.2 -B"
		echo "SIENAx ${SUBJID} is finished"
	fi
done;
