# Brain source based morphometry pipeline
Determine voxel-wise source-based morphometry patterns from lesion-filled 3D-T1 images.  

## Overview

Step | Script
------------- | -------------
Run FSL SIENAx | sienax.sh
Create group template  | template.sh
Register images to template | register2template.sh
Run FSL Melodic | melodic.sh

