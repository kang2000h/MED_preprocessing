addpath C:\User\hkang\MatlabProjects


%% apply skull extracter for individual CT images stored in a directory
input_ct_dirpath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\2_CT FBB  3.0  J30s\changed'
save_dirpath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\2_CT FBB  3.0  J30s\result'
output_prefix = 'skull_'

ct_skull_extracter_for_batch(input_ct_dirpath, save_dirpath, output_prefix)

function ct_skull_extracter_for_batch(input_ct_dirpath, save_dirpath, output_prefix)
    
    input_ct_dirpath(strfind(input_ct_dirpath, '\')) = '/';
    save_dirpath(strfind(save_dirpath, '\')) = '/';
    
    target_filelist=dir(strcat(input_ct_dirpath,'\', '*.nii'));  % w*.nii

    for i=1:length(target_filelist)
        target_file_path = strcat(input_ct_dirpath, '\', target_filelist(i).name);
        % apply_cn_for_sample(target_file_path, ref_filepath, save_path, jobfile_savepath, 1); % inputfile, tpl path, input_dir
        % apply_cn_for_sample_v2(target_file_path, ref_filepath, save_path)
        %apply_cn_for_sample_v3(target_file_path, ref_filepath, save_path)
        ct_skull_extracter(target_file_path, save_dirpath, output_prefix)
    end
end

%% apply skull extracter for a CT image

% input_ct_filepath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\2_CT FBB  3.0  J30s\changed\output.nii'
% save_dirpath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\2_CT FBB  3.0  J30s\result'
% output_prefix = 'before_threshold_'

% ct_skull_extracter(input_ct_filepath, save_dirpath, output_prefix)

function ct_skull_extracter(input_ct_filepath, save_dirpath, output_prefix)
    fprintf('Extracting %s\n', input_ct_filepath)
    
    input_ct_filepath(strfind(input_ct_filepath, '\')) = '/';
    save_dirpath(strfind(save_dirpath, '\')) = '/';
    
    [~, input_filename] = fileparts(input_ct_filepath);
    save_filepath = strcat(save_dirpath, '\', output_prefix, input_filename, '.nii');
    
    target_ct_nii =load_nii(input_ct_filepath);
    size(target_ct_nii.img);
    target_ct_img = target_ct_nii.img;
    
    target_img_size = size(target_ct_img);
    flatten_img = reshape(target_ct_img, [1, target_img_size(1)*target_img_size(2)*target_img_size(3)]);
    
    mean_img = mean(flatten_img);
    std_img = std(flatten_img);
    % save_nii(input_nii, save_path)
    
    z_score_flatten_img = (target_ct_img-mean_img)/std_img;
    output_img = reshape(z_score_flatten_img, [target_img_size(1), target_img_size(2), target_img_size(3)]);
    
    % binarization of voxels with a A-score threshold of 1.5
    output_img(output_img<2.5)=0;
    output_img(output_img>2.5)=1;
    
    target_ct_nii.img = output_img;
    save_nii(target_ct_nii, save_filepath);
end
% apply_dcm2nii(input_dcm_dirpath, output_dcm_dirpath, save_DOTX_jobfile_path)
% 
% function apply_dcm2nii(input_dcm_dirpath, output_dirpath, save_DOTX_jobfile_path)
%     
%     fprintf('Converting %s\n', input_dcm_dirpath);
%     
%     input_dcm_dirpath(strfind(input_dcm_dirpath, '\')) = '/';
%     output_dirpath(strfind(output_dirpath, '\')) = '/';
%     save_DOTX_jobfile_path(strfind(save_DOTX_jobfile_path, '\')) = '/';
%     
%     input_dcm_dirpath;
%     input_filename_stream = '';
%     
%     input_dcm_filelist = dir(input_dcm_dirpath)
%     for i=1:length(input_dcm_filelist)
%         input_dcm_filename = input_dcm_filelist(i).name;
%         input_dcm_filename = strcat(input_dcm_dirpath, '/', input_dcm_filename)
%         if regexp(input_dcm_filename, '\S+.dcm')==1 % check ref_filename havs dcm extension
%             input_filename_stream = string(['''', char(input_dcm_filename), '\n']);
%             
%             input_filename_stream = [input_filename_stream, '''', char(input_dcm_filename), '''\n'];
%         end
%     end
%     input_filename_stream;
%     
%     fout=fopen(save_DOTX_jobfile_path, 'w');
%     
%     job_script = [...
%         'matlabbatch{1}.spm.util.import.dicom.data = {\n'...
%           char(input_filename_stream)...
%           '};\n'...
%         'matlabbatch{1}.spm.util.import.dicom.root = "flat";\n'... % "patid"
%         'matlabbatch{1}.spm.util.import.dicom.outdir = {''%s''};\n'...
%         'matlabbatch{1}.spm.util.import.dicom.protfilter = ".*";\n'...
%         'matlabbatch{1}.spm.util.import.dicom.convopts.format = "nii";\n'...
%         'matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;\n'...
%         'matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;\n'...
% 
%         ];
%     
%    
%     job_script
%     fprintf(fout, job_script, output_dirpath);
%     fclose(fout);
%     
%     jobfile = {save_DOTX_jobfile_path};
%     spm('defaults', 'PET');
%     spm_jobman('run', jobfile);
%     fprintf("[!] Spatial Normalization finished \n")
% 
% end
%     

