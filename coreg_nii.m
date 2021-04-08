ref_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\test_set\coreg\CT\2382_1.3.12.2.1107.5.1.4.11002.30000018091322483671400000786.nii'
input_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\test_set\coreg\PET\2382_1.3.12.2.1107.5.1.4.11002.30000018091402105889900020259.nii'
vol_range = [1:27]
save_jobfile_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\test_set\coreg\run_coreg_job.m'

coreg_nii_without_warp(ref_nii_path, input_nii_path, vol_range, save_jobfile_path)

function coreg_nii_without_warp(ref_nii_path, input_nii_path, vol_range, save_jobfile_path)
    % ARGUMENT DELIMITER '\' -> '/'
    ref_nii_path(strfind(ref_nii_path, '\')) = '/'
    input_nii_path(strfind(input_nii_path, '\')) = '/'
    
    [input_dirpath, input_nii_only_filename] = fileparts(input_nii_path);
    
    % create input_filename_stream
    input_filename_stream = string(['''', char(input_nii_path), ',1''\n']);
    other_input_filename_stream = [];
    if length(vol_range) == 1
        other_input_filename_stream = ''
    elseif length(vol_range)>1
        
        for i = 2:length(vol_range)
            other_input_filename_stream = [other_input_filename_stream, '''', char(input_dirpath), '/', char(input_nii_only_filename), '.nii', ',', int2str(i), '''\n'];
        end
    end
    
    
    input_filename_stream
    other_input_filename_stream
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
    fprintf("[!] program finished\n")
end