#!/bin/bash

if [ "$#" -eq 0 ] 
then
	echo "Usage: ${0##*/} prefix )"
	exit 2
fi

source config.cfg
PREFIX=$1
WORKDIR=${TEMPDIR}
INPUTDIR=${WORKDIR}/input
initial_template=${WORKDIR}/I_brain_to_mni_norm_mean.nii.gz
CURDIR=`pwd`
mkdir -p ${INPUTDIR}

# Create softlinks to datafiles
for DIR in ${DATADIR}/${PREFIX}*
do
	SUBJID=${DIR##*/}
	if [ ! -e ${INPUTDIR}/${SUBJID}_I_brain.nii.gz ]
	then
		ln -s ${DIR}/t1_sienax/I_brain.nii.gz ${INPUTDIR}/${SUBJID}_I_brain.nii.gz
	fi
done;


cd $WORKDIR
antsMultivariateTemplateConstruction2.sh -d 3 -o T_ -b 1 -c 2 -j 6 -y 0 -z $initial_template ${INPUTDIR}/*_I_brain.nii.gz
cd $CURDIR