addpath C:\User\hkang\MatlabProjects

%% apply SN mat obtained from individual CT to individual PET
save_DOTX_jobfile_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\1_MR_based_registration\0_job_scripts\DOTX_in_apply_tpm_nii_mat_on_batch.m';
target_PET_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\1_MR_based_registration\1_coreg_PET';
tx_mat_filedir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\1_MR_based_registration\2_match_MR';
match_PET_save_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\1_MR_based_registration\2_match_PET_to_MR';

apply_sn_mat_for_batch(target_PET_dir, tx_mat_filedir, match_PET_save_path, save_DOTX_jobfile_path)


function apply_sn_mat_for_batch(input_nii_dir, TX_mat_dir, output_dir, save_DOTX_jobfile_path)
    input_nii_filelist = dir(input_nii_dir)
    for i=1:length(input_nii_filelist)
        input_nii_filename = input_nii_filelist(i).name
        
        if regexp(input_nii_filename, '\S+.nii')==1 % check ref_filename havs nii extension
            input_nii_pid = regexp(input_nii_filename, '[\d]{4,}_', 'match') % extract pid
            
%             % check if the input file is already treated
%             save_nii_filelist = dir(output_dir);
%             for i=1:length(save_nii_filelist)
%                 save_nii_filename = save_nii_filelist(i).name;
%                 save_nii_pid = regexp(save_nii_filename, '[\d*]+_', 'match');
%                 if string(cell2mat(input_nii_pid)) == string(cell2mat(save_nii_pid))
%                     break
%                 
%                 end
%             end
            
            target_tx_mat_filename = '';
            TX_mat_filelist = dir(TX_mat_dir);
            for j=1:length(TX_mat_filelist)
                cand_TX_mat_filename = TX_mat_filelist(j).name;
                matched_tag = regexp(cand_TX_mat_filename, '[\d]{4,}_', 'match');
                if length(matched_tag)>=1
                    matched_tag = matched_tag(1) % to discriminate pid from '_sn.mat'
                end
                if startsWith(cand_TX_mat_filename, 'y_') && endsWith(cand_TX_mat_filename, '.nii') && (string(cell2mat(input_nii_pid)) == string(cell2mat(matched_tag)))
                    target_tx_mat_filename = cand_TX_mat_filename;
                    break
                end
            end
            input_nii_filename = strcat(input_nii_dir, '\', input_nii_filename);
            target_tx_mat_filename = strcat(TX_mat_dir, '\', target_tx_mat_filename);
            apply_tpm_nii_mat_for_specific_nii(input_nii_filename, target_tx_mat_filename, save_DOTX_jobfile_path);
        end
    end
    utils.move_specific_files_from_dir(input_nii_dir, output_dir, 'match_');
end

function apply_tpm_nii_mat_for_specific_nii(input_nii_filepath, TX_mat_filepath, save_DOTX_jobfile_path)
    
    fprintf('Normalizing %s\n', input_nii_filepath);
    
    input_nii_filepath(strfind(input_nii_filepath, '\')) = '/'
    TX_mat_filepath(strfind(TX_mat_filepath, '\')) = '/'
    save_DOTX_jobfile_path(strfind(save_DOTX_jobfile_path, '\')) = '/'
    
    input_nii_filepath
    input_filename_stream = ''
    
    if length(input_nii_filepath)==1
        input_filename_stream = string(['''', char(input_nii_filepath), ',1''\n']);
    elseif length(input_nii_filepath) >= 1
        %input_nii = load_nii(input_nii_filepath)
        %for i = utils.arange(1, size(input_nii.img, 4)+1)
        [hk, dime, hist] = load_nii_hdr(input_nii_filepath);
        num_frame = hk.dime.dim(5);
        for i = utils.arange(1, num_frame+1)
            input_filename_stream = [input_filename_stream, '''', char(input_nii_filepath), ',', int2str(i),'''\n'];
        end
    end
    
    fout=fopen(save_DOTX_jobfile_path, 'w');
    
    job_script = [...
        'matlabbatch{1}.spm.spatial.normalise.write.subj.def = {''%s''};\n'...
        'matlabbatch{1}.spm.spatial.normalise.write.subj.resample = { \n'...
          char(input_filename_stream)...
          '};\n'...
        'matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -50\n'...
        '                                                      78 76 84];\n'...  % 78 76 85]
        'matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];\n'...
        'matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;\n'...
        'matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = ''match_'';\n'...
        ];

    %job_script
    fprintf(fout, job_script, TX_mat_filepath);
    fclose(fout);
    
    jobfile = {save_DOTX_jobfile_path};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
    % fprintf("[!] Spatial Normalization finished \n")

end
    
