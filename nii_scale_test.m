test_nii_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\FBB_Delay_ST\5_match_coreg_PET_delay_static_nc_ad';
test_nii_filename = 'match_coreg_11834776_1.3.12.2.1107.5.1.4.11002.30000016042100414583400026349.nii';

nii_file = load_nii(strcat(test_nii_dir, '\', test_nii_filename))
size(nii_file.img, 4) 


what=niftiread(strcat(test_nii_dir, '\', test_nii_filename))


