target_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\canonical';
atlas_filename = 'avg152T1.nii';
save_filename = 'clipped_avg152T1.nii';
full_path = strcat(target_dir, '\', atlas_filename);
save_path = strcat(target_dir, '\', save_filename);
nii = load_nii(full_path)


option.cut_from_L = 6; % x
option.cut_from_R = 6; % x
option.cut_from_P = 7; % y rear
option.cut_from_A = 7; % y front 8->7
option.cut_from_I = 12; % z bottom 1->11
option.cut_from_S = 11; % z top
% option
clipped_nii = clip_nii(nii, option);

save_nii(clipped_nii, save_path);



% save_nii(clipped_nii, save_path);

% old_fn = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test_CT_TO_PET_coreg_ex\CT\kkk.nii'
% new_fn = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test_CT_TO_PET_coreg_ex\CT\resliced_cropped_36361.nii'
% voxel_size = [2, 2, 2]
% reslice_nii(old_fn, new_fn, voxel_size)
