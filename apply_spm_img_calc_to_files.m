
% function rep_spm_img_calc(target_dir, target_filename_list, expression, output_dir, output_filename_list, dtype)
%     for 1:length(target_filename_list)
%         
% end

% for one volume
% save_jobfile_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\test_1PET_DY_static\run_img_calc_arg1.m';
% target_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\test_1PET_DY_static';
% target_filename = 'FBB_BRAIN_DY_ANONYMIZED_190515_091_1.2.410.200055.2.1.2.1707237463.12192.1558059042.273369.nii,1';
% output_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\test_1PET_DY_static';
% output_filename = 'output';
% expression = '(i1)/10';

% for multiple volume
% save_jobfile_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\test_1PET_DY_static\run_img_calc_arg1.m';
% target_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\test_1PET_DY_static';
% target_filename = ["FBB_BRAIN_DY_ANONYMIZED_190515_091_1.2.410.200055.2.1.2.1707237463.12192.1558059042.273369.nii,1", "FBB_BRAIN_DY_ANONYMIZED_190515_091_1.2.410.200055.2.1.2.1707237463.12192.1558059042.273369.nii,2"];
% output_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\test_1PET_DY_static';
% output_filename = 'output';
% expression = '(i1)/10';
% target_filename_stream = strcat(target_dir, '\', target_filename(1));

save_jobfile_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\test_1PET_DY_static\run_img_calc_arg2.m';
target_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\test_1PET_DY_static';
target_filename_list = ["FBB_BRAIN_DY_ANONYMIZED_190515_091_1.2.410.200055.2.1.2.1707237463.12192.1558059042.273369.nii,1", "FBB_BRAIN_DY_ANONYMIZED_190515_091_1.2.410.200055.2.1.2.1707237463.12192.1558059042.273369.nii,2"];
output_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\test_1PET_DY_static';
output_filename = 'output';
expression = '(i1+i2)/10';
% target_filename_stream = strcat(target_dir, '\', target_filename_list(1));
% target_filename_stream = strcat('''', target_dir, '\', target_filename_list(1), '''', '\n', '''', target_dir, '\', target_filename_list(1), '''', '\n');
% target_filename_stream = ''''+string(target_dir)+'\'+target_filename_list(1)+''''+...
% ''''+string(target_dir)+'\'+target_filename_list(2)+''''+'\n';
% disp(target_filename_stream)

% target_filename_list = ["a.nii", "b.nii"];
% nii_vol_filename_list = create_nii_vol_filename_list_with_specific(target_filename_list, [1,2]);
% nii_vol_filename_list


make_spm_img_calc_job(target_dir, target_filename_list, output_dir, output_filename, expression, save_jobfile_path)

function nii_vol_filename_list = create_nii_vol_filename_list_with_specific(target_nii_filename_list, num_vol_list)
    nii_vol_filename_list = []
    for i = 1:length(target_nii_filename_list)
        vol_filename_list = []
        for num_vol = num_vol_list
            vol_filename_list = [vol_filename_list, target_nii_filename_list(i)+','+string(num_vol)]
        end
        nii_vol_filename_list = [nii_vol_filename_list;vol_filename_list]
    end
end

function make_spm_img_calc_job(target_dir, target_filename_list, output_dir, output_filename, expression, save_jobfile_path)
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
        'matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;\n'...
        'matlabbatch{1}.spm.util.imcalc.options.mask = 0;\n'...
        'matlabbatch{1}.spm.util.imcalc.options.interp = 1;\n'...
        'matlabbatch{1}.spm.util.imcalc.options.dtype = 4;\n'...
        ], output_dir, output_filename, expression);

    fclose(fout);
    jobfile = {save_jobfile_path};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
end

function apply_spm_img_calc_on_sample(target_dir, output_dir, output_filename, expression, save_jobfile_path)
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
        'matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;\n'...
        'matlabbatch{1}.spm.util.imcalc.options.mask = 0;\n'...
        'matlabbatch{1}.spm.util.imcalc.options.interp = 1;\n'...
        'matlabbatch{1}.spm.util.imcalc.options.dtype = 4;\n'...
        ], output_dir, output_filename, expression);

    fclose(fout);
    jobfile = {save_jobfile_path};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
end
