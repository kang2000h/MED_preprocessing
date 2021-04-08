addpath C:\User\hkang\MatlabProjects

%% apply dcm2nii for dicom files saved in a directory
% input_dcm_dirpath have to include only directories which have dcm files
save_DOTX_jobfile_path = 'E:\hkang\amyloid\2020\DAUH_dy_200629\1_T1_MR\test\job_scripts\dcm2nii_on_batch_job.m';
input_dcm_dirpath = 'E:\hkang\amyloid\2020\DAUH_dy_200629\1_T1_MR\Dicom\4_T1_MR_APAD';
output_dcm_dirpath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\1_MR_based_registration\Nifti\4_T1_MR_APAD';

apply_dcm2nii_for_batch(input_dcm_dirpath, output_dcm_dirpath, save_DOTX_jobfile_path)

function apply_dcm2nii_for_batch(input_dcm_dirpath, output_dir, save_DOTX_jobfile_path)
    input_dcm_dirlist = dir(input_dcm_dirpath)
    for i=1:length(input_dcm_dirlist)
        input_dcm_dirname = input_dcm_dirlist(i).name
        input_dcm_pid = regexp(input_dcm_dirname, '[\d]{4,}', 'match') % extract pid
        
        if length(input_dcm_pid) > 0
            input_dcm_dirname = strcat(input_dcm_dirpath, '\', input_dcm_dirname);
            apply_dcm2nii(input_dcm_dirname, output_dir, save_DOTX_jobfile_path);
        end
    end
end


% apply_dcm2nii(input_dcm_dirpath, output_dcm_dirpath, save_DOTX_jobfile_path)

function apply_dcm2nii(input_dcm_dirpath, output_dirpath, save_DOTX_jobfile_path)
    
    fprintf('Converting %s\n', input_dcm_dirpath);
    
    input_dcm_dirpath(strfind(input_dcm_dirpath, '\')) = '/';
    output_dirpath(strfind(output_dirpath, '\')) = '/';
    save_DOTX_jobfile_path(strfind(save_DOTX_jobfile_path, '\')) = '/';
    
    input_dcm_dirpath;
    input_filename_stream = '';
    
    input_dcm_filelist = dir(input_dcm_dirpath)
    for i=1:length(input_dcm_filelist)
        input_dcm_filename = input_dcm_filelist(i).name;
        input_dcm_filename = strcat(input_dcm_dirpath, '/', input_dcm_filename)
        if regexp(input_dcm_filename, '\S+.dcm')==1 % check ref_filename havs dcm extension
            %input_filename_stream = string(['''', char(input_dcm_filename), '\n']);
            
            input_filename_stream = [input_filename_stream, '''', char(input_dcm_filename), '''\n'];
        end
    end
    input_filename_stream;
    
    fout=fopen(save_DOTX_jobfile_path, 'w');
    
    job_script = [...
        'matlabbatch{1}.spm.util.import.dicom.data = {\n'...
          char(input_filename_stream)...
          '};\n'...
        'matlabbatch{1}.spm.util.import.dicom.root = "flat";\n'... % "patid"
        'matlabbatch{1}.spm.util.import.dicom.outdir = {''%s''};\n'...
        'matlabbatch{1}.spm.util.import.dicom.protfilter = ".*";\n'...
        'matlabbatch{1}.spm.util.import.dicom.convopts.format = "nii";\n'...
        'matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;\n'...
        'matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;\n'...

        ];
    
   
    %job_script
    fprintf(fout, job_script, output_dirpath);
    fclose(fout);
    
    jobfile = {save_DOTX_jobfile_path};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
    % fprintf("[!] Spatial Normalization finished \n")

end
    

