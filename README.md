# Brain source based morphometry pipeline
Determine voxel-wise source-based morphometry patterns from lesion-filled 3D-T1 images.  

## Overview

Step | Script
------------- | -------------
Run FSL SIENAx | 1_sienax.sh
Create initial template in MNI space  | 2_initialtemplate.sh
Create non-linear group template | 3_grouptemplate.sh
Warp images and pve maps to group template | 4_warp2template.sh
Run FSL Melodic | 5_melodic.sh

