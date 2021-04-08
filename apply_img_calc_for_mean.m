addpath C:\User\hkang\MatlabProjects

% % obtain mean images of dyFBB between defined two boundaries
save_mean_jobfile_path = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\주신 데이터\0_5654578 FBB와 FDG Norm과 cnt norm 진행한거 보내드립니다 _)_201211\mean_FBB\mean_count_match.m';
target_dir = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201222\1_input\1_FBB_67';
output_dir = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201223\6_baseline_time_comp\1_input\1_0to20min_FBB';
% 
% ind_filename_list = dir(target_dir);
% for i=1:length(ind_filename_list);
%     ind_filename = ind_filename_list(i).name;
%     if endsWith(ind_filename, '.nii') 
%         calc_target_filename_list = string(strcat(ind_filename, ',1'))
%         ind_filename;
%         nii_vol_filename_list = create_nii_vol_filename_with_specific(ind_filename, [1]);
%         nii_vol_filename_list;
%         output_filename = [ 'zscore_', ind_filename];    
%         output_filename
%         
%         expression = '(X-mean(X)/std(X)';
%         dmtx = 1;
%         make_spm_img_calc_job(target_dir, nii_vol_filename_list, output_dir, output_filename, expression, save_mean_jobfile_path, dmtx);
%     end
% end

% ind_filename_list = dir(target_dir);
% for i=1:length(ind_filename_list);
%     ind_filename = ind_filename_list(i).name;
%     if endsWith(ind_filename, '.nii') 
%         calc_target_filename_list = string(strcat(ind_filename, ',1'))
%         ind_filename;
%         nii_vol_filename_list = create_nii_vol_filename_with_specific(ind_filename, [1]);
%         nii_vol_filename_list;
%         output_filename = [ 'min_zero_', ind_filename];    
%         output_filename
%         
%         expression = 'X-min(X)';
%         dmtx = 1;
%         make_spm_img_calc_job(target_dir, nii_vol_filename_list, output_dir, output_filename, expression, save_mean_jobfile_path, dmtx);
%     end
% end

%% to make mean static image from dynamic image
ind_filename_list = dir(target_dir);
for i=1:length(ind_filename_list);
    ind_filename = ind_filename_list(i).name;
    if endsWith(ind_filename, '.nii') 
        %calc_target_filename_list = string(strcat(ind_filename, ',1'))
        %ind_filename;
        %nii_vol_filename_list = create_nii_vol_filename_with_specific(ind_filename, [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]);
        %nii_vol_filename_list = create_nii_vol_filename_with_specific(ind_filename, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27]);
        nii_vol_filename_list = create_nii_vol_filename_with_specific(ind_filename, utils.arange(1, 27+1));
        %nii_vol_filename_list;
        output_filename = [ 'mean_0to20min_', ind_filename]
        %output_filename
        
        %expression = '(i1+i2+i3+i4+i5+i6+i7+i8+i9+i10+i11+i12+i3+i4+i5+i6+i7+i8+i19)/19';
        expression = 'mean(X)';
        dmtx=1;
        make_spm_img_calc_job(target_dir, nii_vol_filename_list, output_dir, output_filename, expression, save_mean_jobfile_path, dmtx);
    end
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

