target_dirpath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\3_St_PET_SUV_v2\1_D_PET_nc_ad\3';

setorigin_center(target_dirpath)

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


