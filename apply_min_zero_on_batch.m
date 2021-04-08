target_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\eFBB_FDG_zscoring\4_2_FDG_cnt67_zscoring';
save_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\eFBB_FDG_zscoring\6_minzero_2_FDG_cnt67_zscoring';
output_prefix = 'minzero_';

apply_minzero_on_batch(target_dir, save_dir, output_prefix);

function apply_minzero_on_batch(target_dir, save_dir, output_prefix)
     
    input_filter='*.nii'; 
    
    target_filelist=dir(strcat(target_dir,'\',input_filter));  % w*.nii
    

    for i=1:length(target_filelist)
        target_filepath = strcat(target_dir, '\', target_filelist(i).name);
       
        apply_minzero(target_filepath, save_dir, output_prefix);
    end
end

function apply_minzero(target_filepath, save_filepath, output_prefix)
    fprintf('make the min to zero... %s\n', target_filepath);
    
    target_filepath(strfind(target_filepath, '\')) = '/';
    save_filepath(strfind(save_filepath, '\')) = '/';
    
    target_nii = load_nii(target_filepath);
    target_img = target_nii.img;
   
    % from global minimum
    scaled_img = target_img - min(target_img, [], 'all');
    target_nii.img = scaled_img;
    
    % output filepath
    [~, input_filename] = fileparts(target_filepath);
    output_filepath = strcat(save_filepath, '\', output_prefix, input_filename, '.nii');
    
    save_nii(target_nii, output_filepath);
end
