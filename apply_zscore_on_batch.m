
target_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\eFBB_FDG_zscoring\2_2_FDG_cnt67';
%target_filename = 'mean_1to9min_133468_22_match_norm_cnt.nii';
save_filepath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\eFBB_FDG_zscoring\4_2_FDG_cnt67_zscoring';
mean_filepath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\eFBB_FDG_zscoring\4_2_FDG_cnt67_zscoring\mean\mean_FDG_total.nii';
std_filepath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\eFBB_FDG_zscoring\4_2_FDG_cnt67_zscoring\std\std_FDG_total.nii';

output_prefix = 'zscore_';

target_filepath = strcat(target_dir, '\', target_filename);

%apply_zscore_with_mean_std_files(target_filepath, save_filepath, mean_filepath, std_filepath, output_prefix)
apply_zscore_with_mean_std_files_for_batch(target_dir, save_filepath, mean_filepath, std_filepath, output_prefix)

function apply_zscore_with_mean_std_files_for_batch(target_dir, save_filepath, mean_filepath, std_filepath, output_prefix)
    
    target_filelist=dir(strcat(target_dir,'\', '*.nii'));  % w*.nii

    for i=1:length(target_filelist)
        target_filepath = strcat(target_dir, '\', target_filelist(i).name);
       
        apply_zscore_with_mean_std_files(target_filepath, save_filepath, mean_filepath, std_filepath, output_prefix);
    end
end

function apply_zscore_with_mean_std_files(target_filepath, save_filepath, mean_filepath, std_filepath, output_prefix)
    fprintf('Normalizing %s\n', target_filepath);
    
    target_filepath(strfind(target_filepath, '\')) = '/';
    mean_filepath(strfind(mean_filepath, '\')) = '/';
    std_filepath(strfind(std_filepath, '\')) = '/';
    
    target_nii = load_nii(target_filepath);
    mean_nii = load_nii(mean_filepath);
    std_nii = load_nii(std_filepath);
    
    target_img = target_nii.img;
    mean_img = mean_nii.img;
    std_img = std_nii.img;
    
    normalized_img = (target_img-mean_img)./std_img; % ./ : element-wise division
    target_nii.img = normalized_img;
    
    % output filepath
    [~, input_filename] = fileparts(target_filepath);
    output_filepath = strcat(save_filepath, '\', output_prefix, input_filename, '.nii');
    
    save_nii(target_nii, output_filepath);
end