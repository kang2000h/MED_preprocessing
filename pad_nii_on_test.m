target_dir = 'C:\Users\hkang\hyeon\연구원 활동\하반기 프로젝트\MR_based_Registration\results\1_MR_based_registration\2_spatial_normalization\0_1008688';
target_filename = 'count_match_coreg_1008688_1.3.12.2.1107.5.1.4.11002.30000016042100414583400023257.nii';
save_filename = 'padded_count_match_coreg_1008688_1.3.12.2.1107.5.1.4.11002.30000016042100414583400023257.nii';
full_path = strcat(target_dir, '\', target_filename);
save_path = strcat(target_dir, '\', save_filename);
nii = load_nii(full_path)

%%option.pad_from_L = 6
%%option.pad_from_R = 6
%%option.pad_from_P = 7
%%option.pad_from_A = 7
option.pad_from_I = 12
option.pad_from_S = 0

new_nii = pad_nii(nii, option)

save_nii(new_nii, save_path);




% save_nii(clipped_nii, save_path);

% old_fn = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test_CT_TO_PET_coreg_ex\CT\kkk.nii'
% new_fn = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test_CT_TO_PET_coreg_ex\CT\resliced_cropped_36361.nii'
% voxel_size = [2, 2, 2]
% reslice_nii(old_fn, new_fn, voxel_size)
