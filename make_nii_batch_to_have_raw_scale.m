target_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\total_dy_set\0_PET'
save_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\total_dy_set\1_center_scale_PET'

make_nii_batch_to_have_original_scale(target_nii_path, save_nii_path)

function make_nii_batch_to_have_original_scale(input_dir, save_dir)
    input_filename_list = dir(input_dir);
    for i=1:length(input_filename_list)
        target_filename = input_filename_list(i).name
        if length(target_filename)>4
            input_path = strcat(input_dir, '\', target_filename);
            save_path = strcat(save_dir, '\', target_filename);
            make_nii_to_have_original_scale(input_path, save_path);
        end
    end
end

function make_nii_to_have_original_scale(input_nii_path, save_path)
    % hdr
    target_hdr = load_nii_hdr(input_nii_path)
    
    input_nii = load_nii(input_nii_path)
    input_nii.hdr.dime.scl_slope = target_hdr.dime.scl_slope
    input_nii.hdr.dime.scl_inter = target_hdr.dime.scl_inter
    save_nii(input_nii, save_path)
end



