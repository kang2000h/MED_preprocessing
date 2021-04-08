addpath C:\User\hkang\MatlabProjects



%% apply CN to individual PET which is spatially normalized
input_PETdir = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201223\6_baseline_time_comp\1_input\1_0to20min_FBB';
ref_filepath = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\SUVr\mask\Cerebellum_ADDMASK_AAL3v1.nii';
count_match_PET_save_path = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201223\6_baseline_time_comp\2_CN\1_0to20min_FBB';
jobfile_savepath = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201211\CN\apply_cn_mat_for_batch_by_cb.m'
norm_type = "mean"
%apply_cn_for_sample(input_filepath, ref_filepath, match_PET_save_path)
% conversion_3D_to_4D(target_dir, 'output_16', jobfile_savepath)
% target_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test';
% output_pattern = 'count_'

apply_cn_mat_for_batch(input_PETdir, '*.nii', ref_filepath, count_match_PET_save_path, jobfile_savepath, norm_type)

function apply_cn_mat_for_batch(input_dir, input_filter, ref_filepath, save_path, jobfile_savepath, norm_type)
    %spm_defaults
    if nargin == 0
        input_filter='match_*.nii'; 
    end
    
    target_filelist=dir(strcat(input_dir,'\',input_filter));  % w*.nii

    for i=1:length(target_filelist)
        target_file_path = strcat(input_dir, '\', target_filelist(i).name);
        % apply_cn_for_sample(target_file_path, ref_filepath, save_path, jobfile_savepath, 1); % inputfile, tpl path, input_dir
        % apply_cn_for_sample_v2(target_file_path, ref_filepath, save_path)
        %apply_cn_for_sample_v3(target_file_path, ref_filepath, save_path)
        %apply_cn_for_sample_v4(target_file_path, ref_filepath, save_path, norm_type)
        apply_cn_for_sample_v5(target_file_path, ref_filepath, save_path, norm_type)
        
    end
end

% each frame is normalizaed same value by total sum of intensities of
% global and reference region
function apply_cn_for_sample_v5(input_filepath, ref_filepath, save_path, norm_type)
    tmp_nii = load_nii(input_filepath);
    ori_A = tmp_nii.img;
    
    % tmp_nii.hdr.dime.datatype
    %target_hdr = load_nii_hdr(input_filepath);
    %tmp_nii.hdr = target_hdr;
    %tmp_nii.hdr.dime.datatype=16 % [!]
    ref_nii = load_nii(ref_filepath);
    ref_img = ref_nii.img;
    
    %=============================================
    %[hdr,~]=spm_read_hdr(input_filepath);
    hdr = tmp_nii.original.hdr   
%     scl_slope=hdr.dime.funused1
%     scl_inter=hdr.dime.funused2
    scl_slope=hdr.dime.scl_slope
    scl_inter=hdr.dime.scl_inter
            
    
    %I=niftiread(input_filepath);
    
    native_ori_A =scl_slope*double(ori_A)+scl_inter;
    max(native_ori_A(:))
    %=============================================
    
    spi_list = [];
    sp_list = [];
    for i=1:size(native_ori_A, 4) 
        
        % processing for each volume
        vol_img = native_ori_A(:,:,:,i);
        
        % NaN into 0
        vol_img (isnan(vol_img)==1)=0;
        
       %% scaled vol_img
        %vol_img
        class(vol_img) % 'int16'
        class(ref_img) % 'single'
        type_flag = 0
        if class(vol_img)==string('int16')
            ref_img = int16(ref_img);
            vol_img = int16(vol_img);
            type_flag = 0
        elseif class(vol_img)==string('uint16')
            ref_img = uint16(ref_img);
            type_flag = 1
        elseif class(vol_img)==string('double')
            ref_img = double(ref_img);
            type_flag = 2
        end
        
        % get amount of radioactivity of reference region
        ref_activity = vol_img.*ref_img;
        max(ref_activity(:))
        min(ref_activity(:))
        %spi = sum(ref_activity(:));
        %spi_list = [spi_list, spi];
        spi = reshape(ref_activity, 1, []);
        spi_list = [spi_list, spi];
        
        % get amount of norm of reference region
%         sp = sum(ref_img(:));
%         sp_list = [sp_list, sp];
        sp = reshape(ref_img, 1, []);
        sp_list = [sp_list, sp];

    end
%     [~, input_filename] = fileparts(input_filepath)
%     save_filepath = strcat(save_path, '\count_', input_filename, '.nii')
%     save_untouch_nii(tmp_nii, save_filepath)
    native_new_A = native_ori_A;
    for i=1:size(native_ori_A, 4) 
        
        % processing for each volume
        vol_img = native_ori_A(:,:,:,i);
        
        % NaN into 0
        vol_img (isnan(vol_img )==1)=0;
        
%         total_spi = sum(spi_list(:))
%         total_sp = sum(sp_list(:))
        
        if norm_type == "mean"
            total_spi = sum(spi_list(:))
            total_sp = sum(sp_list(:))
        elseif norm_type == "median"
            total_spi = median(spi_list(spi_list~=0))
            total_sp = median(sp_list(spi_list~=0))
        end
        mc = double(total_spi)/double(total_sp)
        
        SCALE=double(1/mc);
        native_new_A(:,:,:,i) = double(vol_img)*SCALE;
        
        class(tmp_nii.img(:,:,:,i))
        class(vol_img)
        class(SCALE)
        
        
        
    end
    
    new_A=native_new_A;
    [~, input_filename] = fileparts(input_filepath)
   
    
    save_filepath = strcat(save_path, '\count_', input_filename, '.nii')
     %tmp_nii.hdr.dime.datatype = 16;
     %tmp_nii.hdr.dime.bitpix = 32;
     %tmp_nii.filetype=64
    if type_flag==0
        tmp_nii.img = int16(new_A)
    elseif type_flag==1
        tmp_nii.img = uint16(new_A);
    elseif type_flag==2
        tmp_nii.img = double(new_A);
    end
%     tmp_nii.hdr.dime.scl_slope=1.0
%     tmp_nii.hdr.dime.scl_inter=0
    save_nii(tmp_nii, save_filepath)
%     if size(tmp_nii.img, 4) > 1
%         conversion_3D_to_4D(save_path, save_path, 'count_', jobfile_savepath)
%     else
%         utils.move_specific_files_from_dir(save_path, save_path, 'count_')
%     end
end

% each frame is normalizaed same value by total sum of intensities of
% global and reference region
function apply_cn_for_sample_v4(input_filepath, ref_filepath, save_path, norm_type)
    tmp_nii = load_nii(input_filepath);
    
    % tmp_nii.hdr.dime.datatype
    %target_hdr = load_nii_hdr(input_filepath);
    %tmp_nii.hdr = target_hdr;
    tmp_nii.hdr.dime.datatype=16 % [!]
    ref_nii = load_nii(ref_filepath);
    ref_img = ref_nii.img;
    
    %=============================================
    [hdr,~]=spm_read_hdr(input_filepath);
       
    scl_slope=hdr.dime.funused1;
    scl_inter=hdr.dime.funused2;
            
    I=niftiread(input_filepath);
  
    tmp_nii.img =scl_slope*double(I)+scl_inter;
    
    %=============================================
    
    spi_list = [];
    sp_list = [];
    for i=1:size(tmp_nii.img, 4) 
        
        % processing for each volume
        vol_img = tmp_nii.img(:,:,:,i);
        
        % NaN into 0
        vol_img (isnan(vol_img)==1)=0;
        
       %% scaled vol_img
        %vol_img
        class(vol_img) % 'int16'
        class(ref_img) % 'single'
        if class(vol_img)==string('int16')
            ref_img = int16(ref_img);
        elseif class(vol_img)==string('uint16')
            ref_img = uint16(ref_img);
        elseif class(vol_img)==string('double')
            ref_img = double(ref_img);
        end
        
        % get amount of radioactivity of reference region
        ref_activity = vol_img.*ref_img;
        max(ref_activity(:))
        
        %spi = sum(ref_activity(:));
        %spi_list = [spi_list, spi];
        spi = reshape(ref_activity, 1, []);
        spi_list = [spi_list, spi];
        
        % get amount of norm of reference region
%         sp = sum(ref_img(:));
%         sp_list = [sp_list, sp];
        sp = reshape(ref_img, 1, []);
        sp_list = [sp_list, sp];

    end
    
    for i=1:size(tmp_nii.img, 4) 
        
        % processing for each volume
        vol_img = tmp_nii.img(:,:,:,i);
        
        % NaN into 0
        vol_img (isnan(vol_img )==1)=0;
        
%         total_spi = sum(spi_list(:))
%         total_sp = sum(sp_list(:))
        
        if norm_type == "mean"
            total_spi = sum(spi_list(:))
            total_sp = sum(sp_list(:))
        elseif norm_type == "median"
            total_spi = median(spi_list(spi_list~=0))
            total_sp = median(sp_list(spi_list~=0))
        end
        mc = total_spi/total_sp
        
        SCALE=double(1/mc);
        A = double(vol_img)*SCALE;
        tmp_nii.img(:,:,:,i) = A;
        class(tmp_nii.img(:,:,:,i))
        class(vol_img)
        class(SCALE)
    end
    [~, input_filename] = fileparts(input_filepath)
    save_filepath = strcat(save_path, '\count_', input_filename, '.nii')
    tmp_nii.hdr.dime.datatype = 16;
    tmp_nii.hdr.dime.bitpix = 32;
    save_nii(tmp_nii, save_filepath)
%     if size(tmp_nii.img, 4) > 1
%         conversion_3D_to_4D(save_path, save_path, 'count_', jobfile_savepath)
%     else
%         utils.move_specific_files_from_dir(save_path, save_path, 'count_')
%     end
end

% each frame is normalizaed same value by total sum of intensities of
% global and reference region
function apply_cn_for_sample_v3(input_filepath, ref_filepath, save_path)
    tmp_nii = load_nii(input_filepath);
    
    target_hdr = load_nii_hdr(input_filepath);
    tmp_nii.hdr = target_hdr;
    tmp_nii.hdr.dime.datatype=16 % [!]
    ref_nii = load_nii(ref_filepath);
    ref_img = ref_nii.img;
    
    spi_list = [];
    sp_list = [];
    for i=1:size(tmp_nii.img, 4) 
        
        % processing for each volume
        vol_img = tmp_nii.img(:,:,:,i);
        
        % NaN into 0
        vol_img (isnan(vol_img)==1)=0;
        
        % get amount of radioactivity of reference region
        ref_activity = vol_img.*ref_img;
        
        spi = sum(ref_activity(:));
        spi_list = [spi_list, spi];
        
        % get amount of norm of reference region
        sp = sum(ref_img(:));
        sp_list = [sp_list, sp];

    end
    
    for i=1:size(tmp_nii.img, 4) 
        
        % processing for each volume
        vol_img = tmp_nii.img(:,:,:,i);
        
        % NaN into 0
        vol_img (isnan(vol_img )==1)=0;
        
        total_spi = sum(spi_list(:))
        total_sp = sum(sp_list(:))
        mc = total_spi/total_sp
        
        SCALE=double(1/mc);
        tmp_nii.img(:,:,:,i) = double(vol_img*SCALE)
        class(tmp_nii.img(:,:,:,i))
        class(vol_img)
        class(SCALE)
    end
    [~, input_filename] = fileparts(input_filepath)
    save_filepath = strcat(save_path, '\count_', input_filename, '.nii')
    save_nii(tmp_nii, save_filepath)
%     if size(tmp_nii.img, 4) > 1
%         conversion_3D_to_4D(save_path, save_path, 'count_', jobfile_savepath)
%     else
%         utils.move_specific_files_from_dir(save_path, save_path, 'count_')
%     end
end

function apply_cn_for_sample_v2(input_filepath, ref_filepath, save_path)
    tmp_nii = load_nii(input_filepath);
    
    target_hdr = load_nii_hdr(input_filepath);
    tmp_nii.hdr = target_hdr;
    
    ref_nii = load_nii(ref_filepath);
    ref_img = ref_nii.img;
    
    for i=1:size(tmp_nii.img, 4) 
        
        % processing for each volume
        vol_img = tmp_nii.img(:,:,:,i)
        
        % get amount of radioactivity of reference region
        ref_activity = vol_img.*ref_img
        spi = sum(ref_activity(:))
        
        % get amount of norm of reference region
        sp = sum(ref_img(:))
        
        
        mc = spi/sp
        
        SCALE=1/mc;
        tmp_nii.img(:,:,:,i) = vol_img*SCALE
    end
    
    [~, input_filename] = fileparts(input_filepath)
    save_filepath = strcat(save_path, '\count_', input_filename, '.nii')
    save_nii(tmp_nii, save_filepath)
%     if size(tmp_nii.img, 4) > 1
%         conversion_3D_to_4D(save_path, save_path, 'count_', jobfile_savepath)
%     else
%         utils.move_specific_files_from_dir(save_path, save_path, 'count_')
%     end
end

function apply_cn_for_sample(input_filepath, ref_filepath, save_path, jobfile_savepath, use_scale)
    tmp_nii = load_nii(input_filepath)
    for i=1:size(tmp_nii.img, 4) 
        %P={fname,fname_ref};
        f_input_filepath = strcat(input_filepath, ',', int2str(i));
        P={f_input_filepath, ref_filepath};

        [input_dir, input_filename] = fileparts(input_filepath);
        f_input_filename = [input_filename, '.nii,', int2str(i)]
        fname_pi=strcat(input_filename,'_tmp.img');
        hname_pi=strcat(fname_pi(1:end-3),'hdr');

        % sum of (probability * intensity)
        f='i1.*i2'; % element by element product

        spm_imcalc_ui(P,fname_pi,f); % P:input, Q:output, f:expression
        %spm_imcalc_ui(strcat('C:\Users\woody\Downloads\SPM\data\',P), fname_pi,f);

        %[hdr,otherendian]=spm_read_hdr(hname_pi);
        [hdr,~]=spm_read_hdr(hname_pi);
        
        if use_scale==0
            scl_slope=1;
            scl_inter=0;
        else
            scl_slope=hdr.dime.funused1;
            scl_inter=hdr.dime.funused2;
            if scl_slope==0
                scl_slope = 1;
            
            end
        end
        
        %[I,h]=read_anal(fname_pi,'no_scaling');
        [I,~]=read_anal(fname_pi,'no_scaling');
        
        PI=scl_slope*I+scl_inter;
        
        disp("first")
        f_input_filepath
        scl_slope
        scl_inter
        spi=sum(PI(:));   % sum of probability of intensity (pi)

        %disp(spi)

        % sum of probability of intensity 
        f='(i1>-(10^6)).*i2';
        spm_imcalc_ui(P,fname_pi,f);

        %[hdr,otherendian]=spm_read_hdr(hname_pi);
        [hdr,~]=spm_read_hdr(hname_pi);

        if use_scale==0
            scl_slope=1;
            scl_inter=0;
        else
            scl_slope=hdr.dime.funused1;
            scl_inter=hdr.dime.funused2;
            if scl_slope==0
                scl_slope = 1;
            
            end
        end
        
        disp("second")
        scl_slope
        scl_inter
        %[I,h]=read_anal(fname_pi,'no_scaling');
        [I,~]=read_anal(fname_pi,'no_scaling');

        PI=scl_slope*I+scl_inter;
        sp=sum(PI(:));   % sum of probability of intensity 

        %disp(sp)
        str=['!del', ' ', fname_pi];
        eval(str)
        str=['!del', ' ', hname_pi];
        eval(str)

        % probability weighted mean count
%         if spi~=0
%             mc=spi/sp;
%             SCALE=50/mc;
%         else 
%             mc=0;
%             SCALE = 0;
%         end
        mc=spi/sp
        %SCALE=50/mc;
        SCALE=1/mc;
        P=f_input_filename;
        Q=strcat(save_path,'\', 'count_', int2str(i), '_', P);
        f=strcat('i1*',num2str(SCALE));
        spm_imcalc_ui(strcat(input_dir,'\',P),Q,f);
    end
    
    if size(tmp_nii.img, 4) > 1
        conversion_3D_to_4D(save_path, save_path, 'count_', jobfile_savepath)
%     else
%         utils.move_specific_files_from_dir(save_path, save_path, 'count_')
    end
end


function conversion_3D_to_4D(target_dir, save_dir, output_pattern, jobfile_savepath)
    % output_regex_pattern is a pattern to be used instead of original
    % regex_pattern used on target_dir
    
    % find target files whose name include regex_pattern
    target_filelist = [];
    cand_filelist = dir(target_dir);
    
    for i=1:length(cand_filelist)
        cand_filename = cand_filelist(i).name;
        
        if length(cand_filename)>4 & regexp(cand_filename, 'count_[\d]+_')
            target_filelist = [target_filelist, string(strcat(target_dir, '\', cand_filelist(i).name))];
        end
    end
    
    % sorting
    sorted_target_filelist = sort_str_array_with_int_pattern(target_filelist, 'count_[\d]+');
    
    % making stream
    target_filepath_stream = [];
    for i = 1:length(sorted_target_filelist)
        target_filepath = char(sorted_target_filelist(i));
        target_filepath(strfind(target_filepath, '\')) = '/'
        target_filepath
        target_filepath_stream = [target_filepath_stream, '''', char(target_filepath), '''\n'];
    end
    
    % make output iflename
    tmp_output_filename = char(target_filelist(1));
    pattern_ind = regexp(tmp_output_filename, 'count_[\d]+_');
    pattern_to_rm = char(cell2mat(regexp(tmp_output_filename, 'count_[\d]+_', 'match')));
    length(tmp_output_filename);
    output_filename = tmp_output_filename(pattern_ind+length(pattern_to_rm):end);
    output_filename = [output_pattern, output_filename]
    
    % writing job file
    fout = fopen(jobfile_savepath, 'w');
     
    % job script, when creating job script, it's not good to insert a
    % comment or whitespace(\n) between codes
    job_script = [...
    'matlabbatch{1}.spm.util.cat.vols = {\n'...
    char(target_filepath_stream)...
    '                                        };\n'...
    'matlabbatch{1}.spm.util.cat.name = ''%s'';\n'...
    'matlabbatch{1}.spm.util.cat.dtype = 16;\n'...
    'matlabbatch{1}.spm.util.cat.RT = NaN;\n'...
      ]
    %job_script
    fprintf(fout, job_script, output_filename);
    
    fclose(fout);
    
    jobfile = {jobfile_savepath};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
    % fprintf("[!] conversion finished \n")
    
    for i=1:length(sorted_target_filelist)
        str=['!del', ' ', char(sorted_target_filelist(i))];
        eval(str)
    end
    if target_dir~=save_dir
        utils.move_specific_files_from_dir(target_dir, save_dir, 'count_')
    end
end

function sorted_str_list = sort_str_array_with_int_pattern(str_list, regexp_pattern)
    str_tag_list_path = []
    str_tag_list_id = []
    for i=1:length(str_list)
        res = regexp(str_list(i), regexp_pattern, 'match');
        res_mat = cell2mat(res);
        sid = cell2mat(regexp(res_mat, '[\d]+', 'match'))
        str_tag_list_path = [str_tag_list_path, str_list(i)];
        str_tag_list_id = [str_tag_list_id, str2num(sid)];
    end
    
    keySet = str_tag_list_id;
    valueSet = str_tag_list_path;
    M = containers.Map(keySet,valueSet);
    
    sorted_id = sort(str_tag_list_id);
    sorted_str_list = [];
    for i=1:length(sorted_id)
        sorted_str_list = [sorted_str_list, string(M(i))];
    end
end