target_nii_path = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201222\convert_header\2_spm_count\count_mean_0to20min_133468_22_match_norm_cnt.nii';
ref_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Clinical_\scct.nii';

output_save_dir = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201222\convert_header';
output_prefix = 'hdrp_';

replace_nii_header(target_nii_path, ref_nii_path, output_save_dir, output_prefix);

function replace_nii_header(target_nii_path, ref_nii_path, output_save_dir, output_prefix)
    target_nii = load_nii(target_nii_path);
    ref_nii = load_nii(ref_nii_path)
    
    target_nii_img = target_nii.img;
    ref_nii.img = target_nii_img;
    
    [filedir, filename]= fileparts(target_nii_path);
    final_savepath = strcat(output_save_dir, '\', output_prefix, '_', filename, '.nii');

    save_nii(ref_nii, final_savepath)
end
