addpath C:\User\hkang\MatlabProjects

%% apply SN mat obtained from individual CT to individual PET
save_DOTX_jobfile_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\0_job_scripts\DOTX_in_apply_sn_mat_on_batch.m';
target_PET_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\2_CT_based_registration\1_coreg_PET';
tx_mat_filedir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\2_CT_based_registration\2_match_CT';
match_PET_save_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\2_CT_based_registration\2_match_PET_to_CT';

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
                if endsWith(cand_TX_mat_filename, '.mat') && (string(cell2mat(input_nii_pid)) == string(cell2mat(matched_tag)))
                    target_tx_mat_filename = cand_TX_mat_filename;
                    break
                end
            end
            input_nii_filename = strcat(input_nii_dir, '\', input_nii_filename);
            target_tx_mat_filename = strcat(TX_mat_dir, '\', target_tx_mat_filename);
            apply_sn_mat_for_specific_nii(input_nii_filename, target_tx_mat_filename, save_DOTX_jobfile_path);
        end
    end
    utils.move_specific_files_from_dir(input_nii_dir, output_dir, 'match_');
end

function apply_sn_mat_for_specific_nii(input_nii_filepath, TX_mat_filepath, save_DOTX_jobfile_path)
    
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
        'matlabbatch{1}.spm.tools.oldnorm.write.subj.matname = {''%s''};\n'...
        'matlabbatch{1}.spm.tools.oldnorm.write.subj.resample = { \n'...
          char(input_filename_stream)...
          '};\n'...
        'matlabbatch{1}.spm.tools.oldnorm.write.roptions.preserve = 0;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.write.roptions.bb = [-78 -112 -50\n'...
        '                                                      78 76 85];\n'...
        'matlabbatch{1}.spm.tools.oldnorm.write.roptions.vox = [2 2 2];\n'...
        'matlabbatch{1}.spm.tools.oldnorm.write.roptions.interp = 1;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.write.roptions.wrap = [0 0 0];\n'...
        'matlabbatch{1}.spm.tools.oldnorm.write.roptions.prefix = ''match_'';\n'...
        ];

    %job_script
    fprintf(fout, job_script, TX_mat_filepath);
    fclose(fout);
    
    jobfile = {save_DOTX_jobfile_path};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
    % fprintf("[!] Spatial Normalization finished \n")

end
    

function apply_old_normalize_on_batch(input_img_dir, template_path, output_save_path, save_CTSN_jobfile_path)
    input_filenames = dir(input_img_dir)
    
    for i=1:length(input_filenames)
        target_input_filename = input_filenames(i).name
        if length(target_input_filename)>8 && endsWith(target_input_filename, '.nii')
            apply_old_normalize(input_img_dir, target_input_filename, template_path, save_CTSN_jobfile_path)
    
        end
    end
    utils.move_specific_files_from_dir(input_img_dir, output_save_path, 'match_')
    utils.move_specific_files_from_dir(input_img_dir, output_save_path, '.mat')
end

function apply_old_normalize(input_filedir, input_filename, template_path, save_CTSN_jobfile_path)
    fprintf('Normalizing %s\n', strcat(input_filedir, '\', input_filename));

    fout=fopen(save_CTSN_jobfile_path, 'w');
    
    job_script = [...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.source = {''%s\\%s,1''};\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.wtsrc = '''';\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.resample = {''%s\\%s,1''};\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.template = {''%s,1''};\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.weight = '''';\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smosrc = 16;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smoref = 0;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.regtype = ''mni'';\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.cutoff = 25;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.nits = 64;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.reg = 1;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.preserve = 0;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.bb = [-78 -112 -50\n'...
        '                                                         78 76 85];\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.vox = [2 2 2];\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.interp = 1;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.wrap = [1 1 1];\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.prefix = ''match_'';\n'...
        ];

    %job_script
    fprintf(fout, job_script, input_filedir, input_filename, input_filedir, input_filename, template_path);
    fclose(fout);
    
    jobfile = {save_CTSN_jobfile_path};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
    % fprintf("[!] Spatial Normalization finished \n")

end

% ind_filename_list = dir(target_dir);
% for i=1:length(ind_filename_list);
%     ind_filename = ind_filename_list(i).name;
%     if endsWith(ind_filename, '.nii') 
%         nii_filepath = strcat(target_dir, '\', ind_filename);
%         nii_filepath
%         % nii_filepath(strfind(nii_filepath, '\')) = '/'
%         nii = load_untouch_nii(nii_filepath);
%         nii_size = size(nii.img);
%         
%         vol_range = utils.arange(1, nii_size(4)+1);
%         calc_target_filename_list = [];
%         expression = ['('];
%         
%         for v=vol_range
%             calc_target_filename_list= [calc_target_filename_list, string(strcat(ind_filename, ',', int2str(v)))];
%             expression =[expression, strcat('i', int2str(v)), '+'];
%         end
%         calc_target_filename_list
%         output_filename = [ 'mean_', ind_filename];    
%         output_filename
%         expression(length(expression))=')';
%         expression = [expression, strcat('/', int2str(nii_size(4)))]
%         %expression = '(i1+i2)/10';
%         make_spm_img_calc_job(target_dir, calc_target_filename_list, mean_PET_dir, output_filename, expression, save_mean_jobfile_path);
%     end
% end
% 
% % setorigin_center
% setorigin_center(target_dir)
% setorigin_center(mean_PET_dir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% target_filename_stream = strcat(target_dir, '\', target_filename_list(1));
% target_filename_stream = strcat('''', target_dir, '\', target_filename_list(1), '''', '\n', '''', target_dir, '\', target_filename_list(1), '''', '\n');
% target_filename_stream = ''''+string(target_dir)+'\'+target_filename_list(1)+''''+...
% ''''+string(target_dir)+'\'+target_filename_list(2)+''''+'\n';
% disp(target_filename_stream)
% 
% target_filename_list = ["a.nii", "b.nii"];
% nii_vol_filename_list = create_nii_vol_filename_list_with_specific(target_filename_list, [1,2]);
% nii_vol_filename_list
% 
% make_spm_img_calc_job(target_dir, target_filename_list, output_dir, output_filename, expression, save_jobfile_path)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% coreg params
% ref_nii_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test\CT'
% mean_nii_dir = output_dir
% ind_PET_nii_dir = target_dir
% save_jobfile_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test\job_scripts\coreg_for_coreg_in_coreg_multi_vol_nii.m'
% regexp_to_match = '[\d*]+_'
% 
% coreg_mean_PET_save_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test\coreg_mean_PET'
% coreg_ind_PET_save_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test\coreg_PET'
 
% setorigin_center(ref_nii_dir)
% coreg_dynamicPET_list_to_CT_list(ref_nii_dir, mean_nii_dir, ind_PET_nii_dir, save_jobfile_path)

% function coreg_dynamicPET_list_to_CT_list(ref_nii_dir, mean_nii_dir, ind_PET_nii_dir, save_jobfile_path, coreg_mean_PET_save_path, coreg_ind_PET_save_path)
%     ref_nii_filelist = dir(ref_nii_dir);
%     % iterate ref images
%     for i=1:length(ref_nii_filelist)
%         ref_filename = ref_nii_filelist(i).name;
%         fprintf("ref_filename: %s\n", ref_filename);
%         if regexp(ref_filename, '\S+.nii')==1 % check ref_filename havs nii extension
%             ref_pid = regexp(ref_filename, '[\d*]+_', 'match');
%            
%             % find matched mean_PET
%             target_mean_filename = '';
%             mean_nii_filelist = dir(mean_nii_dir);
%             for j=1:length(mean_nii_filelist)
%                 mean_nii_filename = mean_nii_filelist(j).name;
%                 
%                 
%                 if (regexp(mean_nii_filename, '\S+.nii')==1) & (string(cell2mat(ref_pid)) == string(cell2mat(regexp(mean_nii_filename, '[\d*]+_', 'match'))))
%                     target_mean_filename = mean_nii_filename;
%                     
%                     break
%                 end
%             end
%             fprintf("target_mean_filename: %s\n", target_mean_filename);
%             % find matched ind_dynamicPET
%             target_ind_dynamicPET_filename = '';
%             ind_PET_nii_filelist = dir(ind_PET_nii_dir);
%             for j=1:length(ind_PET_nii_filelist)
%                 ind_PET_nii_filename = ind_PET_nii_filelist(j).name;
%                 
%                 if regexp(ind_PET_nii_filename, '[\d*]+_+\S+.nii')==1 & (string(cell2mat(ref_pid)) == string(cell2mat(regexp(ind_PET_nii_filename, '[\d*]+_', 'match'))))
%                     target_ind_dynamicPET_filename = ind_PET_nii_filename;
%                     break
%                 end
%             end
%             fprintf("target_ind_dynamicPET_filename: %s\n", target_ind_dynamicPET_filename);
%             target_ind_dynamicPET_vol_num_list = [];
%             target_ind_dynamicPET_fullpath = strcat(ind_PET_nii_dir, '\', target_ind_dynamicPET_filename);
%             target_ind_dynamicPET_fullpath(strfind(target_ind_dynamicPET_fullpath, '\')) = '/'
%             
%             target_dynamicPET_nii = load_nii(target_ind_dynamicPET_fullpath);
%             dynamicPET_size = size(target_dynamicPET_nii.img);
%             for v=utils.arange(1, dynamicPET_size(4)+1)
%                 target_ind_dynamicPET_vol_num_list = [target_ind_dynamicPET_vol_num_list, string(strcat(target_ind_dynamicPET_fullpath, ',', int2str(v)))];
%             end
%             
%             disp("TEST")
%             ref_nii_dir(strfind(ref_nii_dir, '\')) = '/'
%             mean_nii_dir(strfind(mean_nii_dir, '\')) = '/'
%             
%             ref_filename = strcat(ref_nii_dir, '/', ref_filename)
%             mean_nii_filename = strcat(mean_nii_dir, '/', mean_nii_filename)
%             target_ind_dynamicPET_vol_num_list
%             save_jobfile_path
%             coreg_nii_to_ref(ref_filename, mean_nii_filename, target_ind_dynamicPET_vol_num_list, save_jobfile_path)
%         end
%     end 
%     
%     % move output files to the proper path
%     % for coreg_mean_PET : mean_PET dir -> coreg_mean_PET
%     utils.move_specific_files_from_dir(mean_nii_dir, coreg_mean_PET_save_path, 'coreg_')
%     
%     % for coreg_ind_PET : PET dir -> coreg_PET
%     utils.move_specific_files_from_dir(ind_PET_nii_dir, coreg_ind_PET_save_path, 'coreg_')
% end

% function coreg_nii_to_ref(ref_nii_path, input_nii_path, other_nii_vol_pathlist, save_jobfile_path)
% %%% 
% %
% % other_nii_vol_path_list need to indicate the index of volume such as ['A.nii,1']
% % 
% %
% %
% %%%
% 
%     % ARGUMENT DELIMITER '\' -> '/'
% %     ref_nii_path(strfind(ref_nii_path, '\')) = '/'
% %     input_nii_path(strfind(input_nii_path, '\')) = '/'
%     
%     % create input_filename_stream
%     input_filename_stream = string(['''', char(input_nii_path), ',1''\n']);
%     other_input_filename_stream = [];
%     for i = 1:length(other_nii_vol_pathlist)
%         other_input_filename_stream = [other_input_filename_stream, '''', char(other_nii_vol_pathlist(i)), '''\n'];
%     end
%     other_input_filename_stream
%      % writing job file
%      fout = fopen(save_jobfile_path, 'w');
%      
%      % job script, when creating job script, it's not good to insert a
%      % comment or whitespace(\n) between codes
%      job_script = [...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {''%s,1''};\n'...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.source = { \n'...
%          char(input_filename_stream)...
%          '                                        };\n'...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.other = { \n'...
%           char(other_input_filename_stream)...
%           '};\n'...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = ''nmi'';\n'...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];\n'...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];\n'...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];\n'...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;\n'...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];\n'...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;\n'...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = ''coreg_'';\n'...
%         ]
%     %job_script
%      fprintf(fout, job_script, ref_nii_path);
%     
%     fclose(fout);
%     
%     jobfile = {save_jobfile_path};
%     spm('defaults', 'PET');
%     spm_jobman('run', jobfile);
%     fprintf("[!] coregistration finished \n")
% end

% ref_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\test_set\coreg\CT\2382_1.3.12.2.1107.5.1.4.11002.30000018091322483671400000786.nii'
% input_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\test_set\coreg\PET\2382_1.3.12.2.1107.5.1.4.11002.30000018091402105889900020259.nii'
% vol_range = [1:27]
% save_coreg_jobfile_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\test_set\coreg\run_coreg_job.m'
% 
% 
% 
% 
% 
% coreg_nii_without_warp(ref_nii_path, input_nii_path, vol_range, save_jobfile_path)
% 
% function coreg_multi_vol_nii_to_ref(ref_nii_path, input_nii_path, vol_range, save_jobfile_path)
%     % ARGUMENT DELIMITER '\' -> '/'
%     ref_nii_path(strfind(ref_nii_path, '\')) = '/'
%     input_nii_path(strfind(input_nii_path, '\')) = '/'
%     
%     [input_dirpath, input_nii_only_filename] = fileparts(input_nii_path);
%     
%     % create input_filename_stream
%     input_filename_stream = string(['''', char(input_nii_path), ',1''\n']);
%     other_input_filename_stream = [];
%     if length(vol_range) == 1
%         other_input_filename_stream = ''
%     elseif length(vol_range)>1
%         
%         for i = 2:length(vol_range)
%             other_input_filename_stream = [other_input_filename_stream, '''', char(input_dirpath), '/', char(input_nii_only_filename), '.nii', ',', int2str(i), '''\n'];
%         end
%     end
%     
%     
%     input_filename_stream
%     other_input_filename_stream
%      % writing job file
%      fout = fopen(save_jobfile_path, 'w');
%      
%      % job script, when creating job script, it's not good to insert a
%      % comment or whitespace(\n) between codes
%      job_script = [...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {''%s,1''};\n'...
%          'matlabbatch{1}.spm.spatial.coreg.estwrite.source = { \n'...
%          char(input_filename_stream)...
%          '                                        };\n'...
%         'matlabbatch{1}.spm.spatial.coreg.estwrite.other = { \n'...
%          char(other_input_filename_stream)...
%          '};\n'...
%         'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = ''nmi'';\n'...
%         'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];\n'...
%         'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];\n'...
%         'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];\n'...
%         'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;\n'...
%         'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];\n'...
%         'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;\n'...
%         'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = ''coreg_'';\n'...
%         ]
%     %job_script
%      fprintf(fout, job_script, ref_nii_path);
%     
%     fclose(fout);
%     
%     jobfile = {save_jobfile_path};
%     spm('defaults', 'PET');
%     spm_jobman('run', jobfile);
%     fprintf("[!] program finished\n")
% end



% function make_spm_img_calc_job(target_dir, target_filename_list, output_dir, output_filename, expression, save_jobfile_path)
%     % ARGUMENT DELIMITER '\' -> '/'
%     target_dir(strfind(target_dir, '\')) = '/'
%     output_dir(strfind(output_dir, '\')) = '/'
%     
%     fprintf('calculating img %s\n', target_dir);
%     
% %     target_filename_stream = strcat('''', target_dir, '/', target_filename_list(1), '''', '\n', '''', target_dir, '/', target_filename_list(2), '''', '\n');
% %     fprintf('calculating img %s\n', target_filename_stream);
%     target_filename_stream = []
%     for i = 1:length(target_filename_list)
%         disp(i)
%         target_filename_stream = [target_filename_stream, '''', target_dir, '/', char(target_filename_list(i)), '''\n']
%     end
%     
%     % writing job file
%     fout = fopen(save_jobfile_path, 'w');
%     fprintf(fout, [...
%         'matlabbatch{1}.spm.util.imcalc.input={ \n'...
%         target_filename_stream...
%         '                                        };\n'...
%         'matlabbatch{1}.spm.util.imcalc.outdir = {''%s''};\n'...
%         'matlabbatch{1}.spm.util.imcalc.output = ''%s'';\n'...
%         'matlabbatch{1}.spm.util.imcalc.expression = ''%s'';\n'...
%         'matlabbatch{1}.spm.util.imcalc.var = struct(''name'', {}, ''value'', {});\n'...
%         'matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;\n'...
%         'matlabbatch{1}.spm.util.imcalc.options.mask = 0;\n'...
%         'matlabbatch{1}.spm.util.imcalc.options.interp = 1;\n'...
%         'matlabbatch{1}.spm.util.imcalc.options.dtype = 4;\n'...
%         ], output_dir, output_filename, expression);
% 
%     fclose(fout);
%     jobfile = {save_jobfile_path};
%     spm('defaults', 'PET');
%     spm_jobman('run', jobfile);
% end


% function setorigin_center(varargin)
% % set origin of image files to the center of xyz dimensions using spm
% % functions
% % Fumio Yamashita 2014.1.20
% 
%    %% check arguments
%     if nargin == 0
%         files = spm_select(Inf,'image','Select image files');
%         
%         for i=1:size(files,1)
%             file = deblank(files(i,:));
%             st.vol = spm_vol(file);
%             vs = st.vol.mat\eye(4);
%             vs(1:3,4) = (st.vol.dim+1)/2;
%             spm_get_space(st.vol.fname,inv(vs));
%         end
%     elseif nargin == 1
%         dir_data = varargin{1};
%         %% main loop
%        % spm('welcome');
%        file_source_list = dir(dir_data);
%        
%        length(file_source_list)
%        for i = 1:length(file_source_list)
%            target_filename = file_source_list(i).name;
% 
%            % file_source
%            if endsWith(target_filename, '.nii')
% 
%               %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %           target_filename = deblank(target_filename); % remove whitespace
%     %           target_filename
%     %           test_nii = load_nii(target_filename);
%               %disp("test_nii")
%               %size(test_nii) % 1 1
% 
%     %           fname = target_filename(1:size(target_filename, 2)-4);
%     %           fname
%                %target_file_fullpath = strcat(dir_data, '\', target_filename)
%                %tmp_nii = load_nii(target_file_fullpath);
%                %tmp_nii_size = size(tmp_nii.img)
%                st.vol = spm_vol(strcat(dir_data, '\', target_filename));
%                vol_size = size(st.vol)
%                if vol_size(1)==1
%                    vs = st.vol(1).mat\eye(4); % \ : division
%                    vs(1:3,4) = (st.vol.dim+1)/2;
%                    spm_get_space(st.vol.fname,inv(vs));
%                else
%                    for i=1: vol_size(1)
% %                        st.vol = spm_vol(strcat(dir_data, '\', target_filename, ',', int2str(i)));
% %                        disp("st.vol")
% %                        size(st.vol) % 27 1
% 
%                        vs = st.vol(i).mat\eye(4); % \ : division
%                        
%                        vs(1:3,4) = (st.vol(i).dim+1)/2;
%                        target_filename = strcat(st.vol(i).fname, ',', int2str(i))
%                        
%                        spm_get_space(target_filename,inv(vs));
%                    end
%                end
%            end
%        end
%    
%     else 
%        fprintf('setorigin_center need either none or one of argument\n');
%        return;
%     end
%    
%    
%  end
