target_nii_dir = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201211\input\1_FBB'
target_nii_filename = 'mean_1to9min_133468_22_match_norm_cnt.nii'
save_dir = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201222\convert_header\test2'
save_nii_filename = 'output.nii'

target_nii_path = strcat(target_nii_dir, '\', target_nii_filename);
target_nii = load_nii(target_nii_path)

save_nii_path = strcat(save_dir, '\', save_nii_filename);
size(target_nii.img, 4) 

save_nii(target_nii, save_nii_path)