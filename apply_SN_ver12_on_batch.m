addpath C:\User\hkang\MatlabProjects

%% SN individual to MNI template space when using MR
save_SN_jobfile_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\1_MR_based_registration\0_job_scripts\SN_in_get_sn_mat_from_MR_by_Norm_ver12.m';
ind_input_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\0_Input\2_MR\0_Nifti';
% template_path = 'C:\Users\hkang\PycharmProjects\DynamicPETModeling\datas\5_PET_template\only_eFBB_AN_NC\output\eFBB_2_7min_nc8_float32_lr_avg.nii';
template_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\tpm\TPM.nii'
match_MR_save_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\1_MR_based_registration\2_match_MR'

apply_normalize_with_tpm_on_batch(ind_input_dir, template_path, match_MR_save_path, save_SN_jobfile_path)

function apply_normalize_with_tpm_on_batch(input_img_dir, template_path, output_save_path, save_SN_jobfile_path)
    input_filenames = dir(input_img_dir)
    
    for i=1:length(input_filenames)
        target_input_filename = input_filenames(i).name
        if length(target_input_filename)>8 && endsWith(target_input_filename, '.nii')
            apply_normalize_with_tpm(input_img_dir, target_input_filename, template_path, save_SN_jobfile_path)
    
        end
    end
    utils.move_specific_files_from_dir(input_img_dir, output_save_path, 'match_')
    utils.move_specific_files_from_dir(input_img_dir, output_save_path, 'y_')
end

function apply_normalize_with_tpm(input_filedir, input_filename, template_path, save_SN_jobfile_path)
    fprintf('Normalizing %s\n', strcat(input_filedir, '\', input_filename));

    fout=fopen(save_SN_jobfile_path, 'w');
    
    job_script = [...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {''%s\\%s,1''};\n'...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {''%s\\%s,1''};\n'...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;\n'...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;\n'...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {''%s''};\n'...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = ''mni'';\n'...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];\n'...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;\n'...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;\n'...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -50\n'...
        '                                                         78 76 84];\n'... % 78 76 85] 
        'matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];\n'...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;\n'...
        'matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = ''match_'';\n'...
        ];

    %job_script
    fprintf(fout, job_script, input_filedir, input_filename, input_filedir, input_filename, template_path);
    fclose(fout);
    
    jobfile = {save_SN_jobfile_path};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
    % fprintf("[!] Spatial Normalization finished \n")

end

