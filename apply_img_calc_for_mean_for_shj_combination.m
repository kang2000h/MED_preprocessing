addpath C:\User\hkang\MatlabProjects

% % obtain mean images of dyFBB between defined two boundaries
save_mean_jobfile_path = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201222\time_combination\mean_count_match.m';
target_dir = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201223\1_input\conversion_to_4D';
output_dir = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201223\2_time_combination';

f_index = [1, 3, 6, 9, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26]
%time = [0, 0.5, 1, 1.5, 2, 2.666666667, 3, 3.5, 4, 4.5, 5, 5.5, 6, 7, 8, 9, 10, 15]
num=0
%% to make mean of mean static image from dynamic image
for start_ind=1:length(f_index)
    for end_ind=1:length(f_index)
       if start_ind >= end_ind
           continue
       end
       f_index(start_ind)
       f_index(end_ind)
       num= num+1;
       
       % iterate all files
       tmp_dir_name = ['tmp_', int2str(f_index(start_ind)), 'to', int2str(f_index(end_ind)), 'min'];
       tmp_dir_path = strcat(output_dir, '\', tmp_dir_name);
       %mkdir(tmp_dir_path)
       
       ind_filename_list = dir(target_dir);
       for file_i = 1:length(ind_filename_list)
           ind_filename = ind_filename_list(file_i).name;
           if endsWith(ind_filename, '.nii') 
            
            nii_vol_filename_list = create_nii_vol_filename_with_specific(ind_filename, utils.arange(f_index(start_ind), f_index(end_ind)+1));
            %nii_vol_filename_list = create_nii_vol_filename_with_specific(ind_filename, [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]);
        
            nii_vol_filename_list;
            output_filename = ['tmp_', int2str(f_index(start_ind)), 'to', int2str(f_index(end_ind)), 'min_', ind_filename];    
            %output_filename
            %output_filename = [ 'mean_2to7min_', ind_filename];    
            %expression = '(i1+i2+i3+i4+i5+i6+i7+i8+i9+i10+i11+i12+i3+i4+i5+i6+i7+i8+i19)/19';
            expression = 'mean(X)';
            dmtx=1;
            make_spm_img_calc_job(target_dir, nii_vol_filename_list, output_dir, output_filename, expression, save_mean_jobfile_path, dmtx);
            
            end
       end
       
%        % sum all files in tmp_dir
%        
%        mean_nii_files_list = string_utils.get_child_file_list(tmp_dir_path)
%        len_f_list = length(mean_nii_files_list)
%        mean_nii_files_list = mean_nii_files_list(3:len_f_list)
%        %nii_vol_filename_list;
%        output_filename = ['total_mean_', int2str(f_index(start_ind)), 'to', int2str(f_index(end_ind)), 'min'];    
%            
%        expression = 'mean(X)';
%        dmtx=1;
%        make_spm_img_calc_job(tmp_dir_path, mean_nii_files_list, output_dir, output_filename, expression, save_mean_jobfile_path, dmtx);
%        
%        % remove tmp_dir
%        [status, message, messageid] = rmdir(tmp_dir_path, 's')
    end
    
    

    num
end


function make_spm_img_calc_job(varargin)
    % make_spm_img_calc_job(target_dir, target_filename_list, output_dir, output_filename, expression, save_jobfile_path, [dmtx])
    % 
    target_dir = varargin{1}
    target_filename_list = varargin{2}
    output_dir = varargin{3}
    output_filename = varargin{4}
    expression = varargin{5}
    save_jobfile_path = varargin{6} 
    dmtx = varargin{7}
    % parameter integrity, for dmtx
%     if nargin == 6 & isempty(varargin{7})
%         dmtx = 0;
%     elseif ~isempty(varargin{7})
%         dmtx = double(varargin{7});
%     end
    
    % ARGUMENT DELIMITER '\' -> '/'
    target_dir(strfind(target_dir, '\')) = '/'
    output_dir(strfind(output_dir, '\')) = '/'
    
    fprintf('calculating img %s\n', target_dir);
    
%     target_filename_stream = strcat('''', target_dir, '/', target_filename_list(1), '''', '\n', '''', target_dir, '/', target_filename_list(2), '''', '\n');
%     fprintf('calculating img %s\n', target_filename_stream);
    target_filename_stream = []
    for i = 1:length(target_filename_list)
        disp(i);
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

function vol_filename_list = create_nii_vol_filename_with_specific(target_nii_filename, num_vol_list)
    
    vol_filename_list = []
    for num_vol = num_vol_list
        vol_filename_list = [vol_filename_list, strcat(string(target_nii_filename),",", string(num_vol))]
    end
   
end

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

