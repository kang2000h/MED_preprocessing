%irm_normalize_0520('E:\SPM\spm_sample', 'E:\SPM\spm12\toolbox\OldNorm\SPECT.nii', 1, 'E:\SPM\spm_sample\result')
function irm_normalize_0520_FBB_tmp_110(varargin)
    if nargin ~= 4
       fprintf('irm_normalize(<data_dir>, <template_file>, <cnt_option>, <result_dir>)\n');
       return;
    end
    
    if ~isdeployed 
        % A directory that spm matlab files exist
        addpath E:\SPM\spm12
        addpath E:\SPM\irm_normalize_files
    end

    % A directory that data files exist
    %dir_data = '/home/samuelchoi/Programs/spm12/dauh_normalize/12967137';
    dir_data = varargin{1}; %'E:\SPM\spm_sample';

    % Specifying SPECT template file
    %file_template = '/home/samuelchoi/Programs/spm12/toolbox/OldNorm/PET.nii';
    file_template = varargin{2}; % 'E:\SPM\spm12\toolbox\OldNorm\SPECT.nii';
    
    % Specifying reference region for count normalizing
    cnt_option = varargin{3}; % 1;
    
    % A directory that result data files will be saved
    dir_result = varargin{4}; % 'E:\SPM\spm_sample\result';
    
    % A temporary file to record normalising arguments
    file_arg = 'E:\SPM\\run_normalise_arg.m';

    file_source_list = dir(dir_data);
    for i = 1:length(file_source_list)
        file_source = file_source_list(i).name;
        if endsWith(file_source, '.nii') && ~endsWith(file_source, 'lr.nii')
            fprintf('Flipping %s\n', file_source);
            flip_lr(strcat(dir_data, '\', file_source), strrep(strcat(dir_data, '\', file_source), '.nii', 'lr.nii'));
        end
    end
    
    spm('welcome');
    file_source_list = dir(dir_data);
    for i = 1:length(file_source_list)
        file_source = file_source_list(i).name;
        if endsWith(file_source, 'lr.nii') && ~startsWith(file_source, 'w') && ~startsWith(file_source, 'cw') && ~startsWith(file_source, 'scw')
            do_normalize(file_source, dir_data, file_template, file_arg);
        end
    end
    
    
    spm8_cntnor('w*.nii', dir_data, cnt_option);
    
    file_source_list = dir(dir_data);
    for i = 1:length(file_source_list)
        file_source = file_source_list(i).name;
        if endsWith(file_source, '.nii') && startsWith(file_source, 'cw')
            do_smooth(file_source, dir_data, file_arg);
        end
    end
    
    file_source_list = dir(dir_data);
    for i = 1:length(file_source_list)
        file_source = file_source_list(i).name;
        if endsWith(file_source, '.nii') && startsWith(file_source, 'scw')
            fprintf('Converting to hdr/img format %s\n', file_source);
            nii = load_untouch_nii(strcat(dir_data, '\', file_source));
            nii.hdr.hist.magic(1:3) = 'ni1';
            save_untouch_nii(nii, strrep(file_source, '.nii', ''));
            movefile(strrep(file_source, '.nii', '.img'),dir_result);
            movefile(strrep(file_source, '.nii', '.hdr'),dir_result);
        end
    end
end

function do_normalize(file_source, dir_data, file_template, file_arg)
    fprintf('Normalizing %s\n', file_source);

    fout=fopen(file_arg, 'w');
    fprintf(fout,[...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.source={''%s\\%s,1''};\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.wtsrc = {''''};\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.resample = {''%s\\%s,1''};\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.template = {''%s,1''};\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.weight = {''''};\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smosrc = 8;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smoref = 0;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.regtype = ''mni'';\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.cutoff = 25;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.nits = 16;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.reg = 1;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.preserve = 0;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.bb = [-82 -98 -82\n'... % default[-78 -112 -50    raw_PET [-203 -203 -82      CT_tmp [-82 -98 -82
        '82 98 82];\n'...                                                            %        78 76 85]                 204 204 82]               82 98 82]  
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.vox = [1.0 1.0 1.5];\n'... %     [2 2 2]                 [1.02 1.02 1.50]            [1 1 1.5]  
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.interp = 1;\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.wrap = [0 0 0];\n'...
        'matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.prefix = ''w'';\n'],...
        dir_data, file_source, dir_data, file_source, file_template);
    fclose(fout);
    jobfile = {file_arg};%{'/tmp/aa_job.m'};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
end

function do_smooth(file_source, dir_data, file_arg)
    fprintf('Smoothing %s\n', file_source);

    fout=fopen(file_arg, 'w');
    fprintf(fout,[...
        'matlabbatch{1}.spm.spatial.smooth.data = {''%s\\%s,1''};\n'...
        'matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];\n'... % 16 > 8
        'matlabbatch{1}.spm.spatial.smooth.dtype = 0;\n'...
        'matlabbatch{1}.spm.spatial.smooth.im = 0;\n'...
        'matlabbatch{1}.spm.spatial.smooth.prefix = ''s'';\n'],...
        dir_data, file_source);
    fclose(fout);
    jobfile = {file_arg};%{'/tmp/aa_job.m'};
    spm('defaults', 'PET');
    spm_jobman('run', jobfile);
end

function spm8_cntnor(filter, dir_data, cnt_option)

    addpath E:\SPM\spm12\compat
    spm_defaults

    if nargin == 0
        filter='s*.img'; 
    end
    
    % s=which('spm8_cntnor');
    pdir='E:\SPM\cerebellar_mask_\fix2';
    %pdir='E:\SPM\cerebellar_mask_test_';
    %flist_ref=dir(strcat(pdir,'\*.img'));
    flist_ref=dir(strcat(pdir,'\*.nii')); 
    disp('Reference regions ...')

    for i=1:length(flist_ref)
       fname_ref=flist_ref(i).name;
       str=[num2str(i),')',' ', fname_ref(1:end-4)];
       disp(str); 
    end

    rid=cnt_option; % input('Select region to normalize: ');
    disp('Select region to normalize: ...')
    disp(rid);

    fname_ref=strcat(pdir,'\',flist_ref(rid).name);
    flist=dir(strcat(dir_data,'\',filter));  % w*.nii

    for i=1:length(flist)
        spm8_cntnor_main(flist(i).name,fname_ref, dir_data); % inputfile, tpl path, input_dir
    end
end
%__________________________________________________________________________

function spm8_cntnor_main(fname,fname_ref, dir_data)

    %P={fname,fname_ref};
    P={strcat(dir_data,'\',fname),fname_ref};

    fname_pi=strcat(fname(1:end-4),'_tmp.img');
    hname_pi=strcat(fname_pi(1:end-3),'hdr');

    % sum of (probability * intensity)
    f='i1.*i2'; % element by element product
    
    spm_imcalc_ui(P,fname_pi,f); % P:input, Q:output, f:expression
    %spm_imcalc_ui(strcat('C:\Users\woody\Downloads\SPM\data\',P), fname_pi,f);

    %[hdr,otherendian]=spm_read_hdr(hname_pi);
    [hdr,~]=spm_read_hdr(hname_pi);

    scl_slope=hdr.dime.funused1;
    scl_inter=hdr.dime.funused2;

    %[I,h]=read_anal(fname_pi,'no_scaling');
    [I,~]=read_anal(fname_pi,'no_scaling');

    PI=scl_slope*I+scl_inter;

    spi=sum(PI(:));   % sum of probability

    %disp(spi)

    % sum of probability
    f='(i1>-(10^6)).*i2';
    spm_imcalc_ui(P,fname_pi,f);

    %[hdr,otherendian]=spm_read_hdr(hname_pi);
    [hdr,~]=spm_read_hdr(hname_pi);

    scl_slope=hdr.dime.funused1;
    scl_inter=hdr.dime.funused2;

    %[I,h]=read_anal(fname_pi,'no_scaling');
    [I,~]=read_anal(fname_pi,'no_scaling');

    PI=scl_slope*I+scl_inter;
    sp=sum(PI(:));   % sum of probability

    %disp(sp)
    str=['!del', ' ', fname_pi];
    eval(str)
    str=['!del', ' ', hname_pi];
    eval(str)

    % probability weighted mean count
    mc=spi/sp;
    SCALE=50/mc;
    P=fname;
    Q=strcat(dir_data,'\c',P);
    f=strcat('i1*',num2str(SCALE));
    spm_imcalc_ui(strcat(dir_data,'\',P),Q,f);

% hname=strcat(fname(1:end-3),'hdr');
%    
% [hdr,otherendian]=spm_read_hdr(hname);
% 
% scl_slope=hdr.dime.funused1;
% scl_inter=hdr.dime.funused2;
%  
% [I,h]=read_anal(fname_ref,'no_scaling');
% 
% I=scl_slope*I+scl_inter;
% 
% I.*Ref
% sp=sum(I(:));   % sum of probability
end

function flip_lr(original_fn, flipped_fn, old_RGB, tolerance, preferredForm)

   if ~exist('original_fn','var') | ~exist('flipped_fn','var')
      error('Usage: flip_lr(original_fn, flipped_fn, [old_RGB],[tolerance])');
   end

   if ~exist('old_RGB','var') | isempty(old_RGB)
      old_RGB = 0;
   end

   if ~exist('tolerance','var') | isempty(tolerance)
      tolerance = 0.1;
   end

   if ~exist('preferredForm','var') | isempty(preferredForm)
      preferredForm= 's';				% Jeff
   end

   nii = load_nii(original_fn, [], [], [], [], old_RGB, tolerance, preferredForm);
   M = diag(nii.hdr.dime.pixdim(2:5));
   M(1:3,4) = -M(1:3,1:3)*(nii.hdr.hist.originator(1:3)-1)';
   M(1,:) = -1*M(1,:);
   nii.hdr.hist.sform_code = 1;
   nii.hdr.hist.srow_x = M(1,:);
   nii.hdr.hist.srow_y = M(2,:);
   nii.hdr.hist.srow_z = M(3,:);
   save_nii(nii, flipped_fn);
end					% flip_lr
