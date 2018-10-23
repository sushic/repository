echo "fange an mit Bas"
#!/bin/bash

echo "fange an"

3dTcat -overwrite -prefix Basis_0a.nii ./S*.nii'[4..7]' ./S*.nii'[4..$]'

cp ./Basis_0a.nii ./Basis_0b.nii


echo "hole SPM motion batch"
cp /Users/huberl/NeuroDebian/repository/moco/mocobatch100_VASO.m ./mocobatch100_VASO.m
/Applications/MATLAB_R2016a.app/bin/matlab -nodesktop -nosplash -r "mocobatch100_VASO"

gnuplot "/Users/huberl/NeuroDebian/repository/moco/gnuplot_moco.txt"

rm ./Basis_0a.nii ./Basis_0b.nii

NumVol=`3dinfo -nv Nulled_Basis_0b.nii`
3dcalc -a Nulled_Basis_0b.nii'[3..'`expr $NumVol - 2`']' -b  Not_Nulled_Basis_0a.nii'[3..'`expr $NumVol - 2`']' -expr 'a+b' -prefix combined.nii -overwrite
3dTstat -cvarinv -prefix T1_weighted.nii -overwrite combined.nii 
rm combined.nii

3dcalc -a Nulled_Basis_0b.nii'[1..$(2)]' -expr 'a' -prefix Nulled.nii -overwrite
3dcalc -a Not_Nulled_Basis_0a.nii'[0..$(2)]' -expr 'a' -prefix BOLD.nii -overwrite

3drefit -space ORIG -view orig -TR 3 BOLD.nii
3drefit -space ORIG -view orig -TR 3 Nulled.nii

3dTstat -mean -prefix mean_nulled.nii Nulled.nii -overwrite
3dTstat -mean -prefix mean_notnulled.nii BOLD.nii -overwrite


3dUpsample -overwrite  -datum short -prefix Nulled_intemp.nii -n 2 -input Nulled.nii
3dUpsample -overwrite  -datum short -prefix BOLD_intemp.nii   -n 2 -input   BOLD.nii

NumVol=`3dinfo -nv BOLD_intemp.nii`

3dTcat -overwrite -prefix Nulled_intemp.nii Nulled_intemp.nii'[0]' Nulled_intemp.nii'[0..'`expr $NumVol - 2`']' 

## you only ned this is the first image is a VASO image
#  3dcalc -prefix tmp.VASO_vol1.nii \
#         -a      Nulled_intemp.nii'[0]' \
#         -b      BOLD_intemp.nii'[0]' \
#         -expr '(a/b-step(a/b-2)*(a/b-1))*step(a/b)' -overwrite
         
#  3dcalc -prefix tmp.VASO_vollast.nii \
#         -b      Nulled_intemp.nii'[$]' \
#         -a      BOLD_intemp.nii'[$]' \
#         -expr 'b/a' -overwrite



#  3dcalc -prefix tmp.VASO_othervols.nii \
#         -b      BOLD_intemp.nii'[1..$]' \
#         -a      Nulled_intemp.nii'[0..'`expr $NumVol - 2`']' \
#         -expr '(a/b-step(a/b-2)*(a/b-1))*step(a/b)' -overwrite
  
# 3dTcat -overwrite -prefix VASO_intemp.nii tmp.VASO_vol1.nii tmp.VASO_othervols.nii 
#rm tmp.VASO_vol1*.nii tmp.VASO_othervols*.nii tmp.VASO_vollast.nii

LN_BOCO -Nulled Nulled_intemp.nii -BOLD BOLD_intemp.nii 

  3dTstat  -overwrite -mean  -prefix BOLD.Mean.nii \
     BOLD_intemp.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix BOLD.tSNR.nii \
     BOLD_intemp.nii'[1..$]'
  3dTstat  -overwrite -mean  -prefix VASO.Mean.nii \
     VASO_intemp.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix VASO.tSNR.nii \
     VASO_intemp.nii'[1..$]'


start_bias_field.sh T1_weighted.nii

echo "und tschuess"