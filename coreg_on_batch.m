addpath C:\User\hkang\MatlabProjects

%% min-zero CT
% save_minzero_jobfile_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\total_dy_set\0_job_scripts\min_zero_for_coreg_in_coreg_multi_vol_nii.m';
% target_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\total_dy_set\0_CT';
% minzero_CT_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\total_dy_set\1_minzero_CT';
% 
% ind_filename_list = dir(target_dir);
% for i=1:length(ind_filename_list);
%     ind_filename = ind_filename_list(i).name;
%     if endsWith(ind_filename, '.nii') 
%         calc_target_filename_list = string(strcat(ind_filename, ',1'))
%         output_filename = [ 'minzero_', ind_filename];    
%         output_filename
%         
%         expression = 'X-min(X)'
%         
%         dmtx=1
%         make_spm_img_calc_job(target_dir, calc_target_filename_list, minzero_CT_dir, output_filename, expression, save_minzero_jobfile_path, dmtx);
%     end
% end

% %% coreg params
input_nii_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\0_Input\0_PET\Nifti\1_delay'
ref_pet_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\2_CT_based_registration\0_minzero'
% ind_PET_nii_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test\PET'
save_jobfile_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\0_job_scripts\coreg_nii.m'
% regexp_to_match = '[\d*]+_'

% coreg_mean_PET_save_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test\coreg_mean_PET'
% coreg_ind_PET_save_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test\coreg_PET'
coreg_save_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\2_CT_based_registration\1_coreg_PET'

% setorigin_center(ref_nii_dir)
% coreg_dynamicPET_list_to_CT_list(ref_nii_dir, mean_pet_dir, ind_PET_nii_dir, save_jobfile_path)
coreg_nii_on_batch(ref_pet_dir, input_nii_dir, save_jobfile_path, coreg_save_path)

function coreg_nii_on_batch(ref_nii_dir, input_nii_dir, save_jobfile_path, output_path)
    ref_nii_filelist = dir(ref_nii_dir);
    % iterate ref images -> iterate target image.(?)
    for i=1:length(ref_nii_filelist)
        ref_filename = ref_nii_filelist(i).name;
        if length(ref_filename) < 4
           continue 
        end
        % check redundancy
        ref_pid = regexp(ref_filename, '[\d]{4,}_', 'match'); % '[\d*]+_',
        ref_pid = cell2mat(ref_pid);
        str_to_test = ''
        save_path_filename_list = dir(output_path);
        for i=1:length(save_path_filename_list)
            str_to_test = [str_to_test, char(save_path_filename_list(i).name)];
        end
        ind_list = regexp(str_to_test, ref_pid, 'match');
        if length(ind_list)~=0
            continue
        end
        
        fprintf("ref_filename: %s\n", ref_filename);
        if regexp(ref_filename, '\S+.nii')==1 % check ref_filename havs nii extension
            ref_pid = regexp(ref_filename, '[\d]{4,}_', 'match'); % extract pid
           
            % find matching CT
            target_input_nii_filename = '';
            input_nii_filelist = dir(input_nii_dir);
            for j=1:length(input_nii_filelist)
                input_nii_filename = input_nii_filelist(j).name;
                if length(input_nii_filename)>4
                    if (regexp(input_nii_filename, '\S+.nii')==1) & (string(cell2mat(ref_pid)) == string(cell2mat(regexp(input_nii_filename, '[\d*]+_', 'match'))))
                        target_input_nii_filename = input_nii_filename;
                        break;
                    end
                end
            end
            fprintf("target_input_nii_filename: %s\n", target_input_nii_filename);
            
            if length(target_input_nii_filename)==0
                continue
            end
            disp("TEST")
            ref_nii_dir(strfind(ref_nii_dir, '\')) = '/'
            input_nii_dir(strfind(input_nii_dir, '\')) = '/'
            
            ref_filename = strcat(ref_nii_dir, '/', ref_filename)
            target_input_nii_filename = strcat(input_nii_dir, '/', target_input_nii_filename)
            coreg_nii_to_ref(ref_filename, target_input_nii_filename, [], save_jobfile_path)
        end
    end
    % for coreg_ind_PET : PET dir -> coreg_PET
    utils.move_specific_files_from_dir(input_nii_dir, output_path, 'coreg_')
    fprintf("[!] coregistration finished")
end


function coreg_nii_to_ref(ref_nii_path, input_nii_path, other_nii_vol_pathlist, save_jobfile_path)
%%% 
%
% other_nii_vol_path_list need to indicate the index of volume such as ['A.nii,1']
% 
%
%
%%%

    % ARGUMENT DELIMITER '\' -> '/'
%     ref_nii_path(strfind(ref_nii_path, '\')) = '/'
%     input_nii_path(strfind(input_nii_path, '\')) = '/'
    
    % create input_filename_stream
    input_filename_stream = string(['''', char(input_nii_path), ',1''\n']);
    other_input_filename_stream = [];
    if length(other_nii_vol_pathlist) >= 1
        for i = 1:length(other_nii_vol_pathlist)
            other_input_filename_stream = [other_input_filename_stream, '''', char(other_nii_vol_pathlist(i)), '''\n'];
        end
    else
        other_input_filename_stream='''''';
    end
    
    
     % writing job file
     fout = fopen(save_jobfile_path, 'w');
     
     % job script, when creating job script, it's not good to insert a
     % comment or whitespace(\n) between codes
     job_script = [...
         'matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {''%s,1''};\n'...
         'matlabbatch{1}.spm.spatial.coreg.estwrite.source = { \n'...
         char(input_filename_stream)...
         '                                        };\n'...
         'matlabbatch{1}.spm.spatial.coreg.estwrite.other = { \n'...
          char(other_input_filename_stream)...
          '};\n'...
         'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = ''nmi'';\n'...
         'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];\n'...
         'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];\n'...
         'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];\n'...
         'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;\n'...
         'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];\n'...
         'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;\n'...
         'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = ''coreg_'';\n'...
        ]
    %job_script
     fprintf(fout, job_script, ref_nii_path);
    
    fclose(fout);
    
    jobfile = {save_jobfile_path};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
    fprintf("[!] coregistration finished \n")
end

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



function make_spm_img_calc_job(varargin)
    % make_spm_img_calc_job(target_dir, target_filename_list, output_dir, output_filename, expression, save_jobfile_path, [dmtx])
    % 
    target_dir = varargin{1}
    target_filename_list = varargin{2}
    output_dir = varargin{3}
    output_filename = varargin{4}
    expression = varargin{5}
    save_jobfile_path = varargin{6} 
    
    % parameter integrity, for dmtx
    if nargin == 6 & isempty(varargin{7})
        dmtx = 0;
    elseif ~isempty(varargin{7})
        dmtx = double(varargin{7});
    end
    % ARGUMENT DELIMITER '\' -> '/'
    target_dir(strfind(target_dir, '\')) = '/'
    output_dir(strfind(output_dir, '\')) = '/'
    
    fprintf('calculating img %s\n', target_dir);
    
%     target_filename_stream = strcat('''', target_dir, '/', target_filename_list(1), '''', '\n', '''', target_dir, '/', target_filename_list(2), '''', '\n');
%     fprintf('calculating img %s\n', target_filename_stream);
    target_filename_stream = []
    for i = 1:length(target_filename_list)
        disp(i)
        target_filename_stream = [target_filename_stream, '''', target_dir, '/', char(target_filename_list(i)), '''\n']
    end
    
    % writing job file
    fout = fopen(save_jobfile_path, 'w');
    fprintf(fout, [...
        'matlabbatch{1}.spm.util.imcalc.input={ \n'...
        target_filename_stream...
        '                                        };\n'...
        'matlabbatch{1}.spm.util.imcalc.outdir = {''%s''};\n'...
        'matlabbatch{1}.spm.util.imcalc.output = ''%s'';\n'...
        'matlabbatch{1}.spm.util.imcalc.expression = ''%s'';\n'...
        'matlabbatch{1}.spm.util.imcalc.var = struct(''name'', {}, ''value'', {});\n'...
        'matlabbatch{1}.spm.util.imcalc.options.dmtx = %d;\n'...
        'matlabbatch{1}.spm.util.imcalc.options.mask = 0;\n'...
        'matlabbatch{1}.spm.util.imcalc.options.interp = 1;\n'...
        'matlabbatch{1}.spm.util.imcalc.options.dtype = 4;\n'...
        ], output_dir, output_filename, expression, dmtx);

    fclose(fout);
    jobfile = {save_jobfile_path};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
end


function setorigin_center(varargin)
% set origin of image files to the center of xyz dimensions using spm
% functions
% Fumio Yamashita 2014.1.20

   %% check arguments
    if nargin == 0
        files = spm_select(Inf,'image','Select image files');
        
        for i=1:size(files,1)
            file = deblank(files(i,:));
            st.vol = spm_vol(file);
            vs = st.vol.mat\eye(4);
            vs(1:3,4) = (st.vol.dim+1)/2;
            spm_get_space(st.vol.fname,inv(vs));
        end
    elseif nargin == 1
        dir_data = varargin{1};
        %% main loop
       % spm('welcome');
       file_source_list = dir(dir_data);
       
       length(file_source_list)
       for i = 1:length(file_source_list)
           target_filename = file_source_list(i).name;

           % file_source
           if endsWith(target_filename, '.nii')

              %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %           target_filename = deblank(target_filename); % remove whitespace
    %           target_filename
    %           test_nii = load_nii(target_filename);
              %disp("test_nii")
              %size(test_nii) % 1 1

    %           fname = target_filename(1:size(target_filename, 2)-4);
    %           fname
               %target_file_fullpath = strcat(dir_data, '\', target_filename)
               %tmp_nii = load_nii(target_file_fullpath);
               %tmp_nii_size = size(tmp_nii.img)
               st.vol = spm_vol(strcat(dir_data, '\', target_filename));
               vol_size = size(st.vol)
               if vol_size(1)==1
                   vs = st.vol(1).mat\eye(4); % \ : division
                   vs(1:3,4) = (st.vol.dim+1)/2;
                   spm_get_space(st.vol.fname,inv(vs));
               else
                   for i=1: vol_size(1)
%                        st.vol = spm_vol(strcat(dir_data, '\', target_filename, ',', int2str(i)));
%                        disp("st.vol")
%                        size(st.vol) % 27 1

                       vs = st.vol(i).mat\eye(4); % \ : division
                       
                       vs(1:3,4) = (st.vol(i).dim+1)/2;
                       target_filename = strcat(st.vol(i).fname, ',', int2str(i))
                       
                       spm_get_space(target_filename,inv(vs));
                   end
               end
           end
       end
   
    else 
       fprintf('setorigin_center need either none or one of argument\n');
       return;
    end
   
   
 end
