target_nii_path = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201211\CN\2_CN_CbGM\1_FBB\count_mean_1to9min_133468_22_match_norm_cnt.nii';
target_nii =load_nii(target_nii_path);

comp_nii_path = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201211\FBB\mean_1to9min_133468_22_match_norm_cnt.nii';
comp_nii =load_nii(target_nii_path);

sum(target_nii.img == comp_nii.img, 'all')
numel(target_nii.img == comp_nii.img)

size(target_nii.img)
%test = reshape(target_nii.img, [128, 128, 110, 27])
% target_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test\scale_test\original'
% save_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test\scale_test\output'


% target_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test\PET\test\6982_1.3.12.2.1107.5.1.4.11002.30000018012904254840500006163.nii'
% save_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test\PET\test\6982.nii'

% target_hdr = load_nii_hdr(target_nii_path);
% target_hdr.dime.scl_slope
% target_hdr.dime.datatype
% target_hdr.dime.scl_slope

% target_nii = load_nii(save_nii_path);
% mean(target_nii.img(:))

% target_nii.hdr.dime.scl_slope=target_hdr.dime.scl_slope
% target_nii.hdr.dime.datatype=target_hdr.dime.datatype
% target_nii.hdr = target_hdr;
% save_nii(target_nii, save_nii_path)

% make_nii_batch_to_have_original_scale(target_nii_path, save_nii_path)
% 
% function make_nii_batch_to_have_original_scale(input_dir, save_dir)
%     input_filename_list = dir(input_dir);
%     for i=1:length(input_filename_list)
%         target_filename = input_filename_list(i).name
%         if length(target_filename)>4
%             input_path = strcat(input_dir, '\', target_filename);
%             save_path = strcat(save_dir, '\', target_filename);
%             make_nii_to_have_original_scale(input_path, save_path);
%         end
%     end
% end
% 
% function make_nii_to_have_original_scale(input_nii_path, save_path)
%     % hdr
%     target_hdr = load_nii_hdr(input_nii_path)
%     
%     input_nii = load_nii(input_nii_path)
%     input_nii.hdr.dime.scl_slope = target_hdr.dime.scl_slope
%     input_nii.hdr.dime.scl_inter = target_hdr.dime.scl_inter
%     save_nii(input_nii, save_path)
% end
%target_str = 'Hello World';
%expression = 'B';
%regexp(target_str, expression)
% strfind(target_str, expression)

%utils.arange(1, 4)
%regexp = 'mean_';위치 1의 인덱스가 배열 경계를 초과합니다(1을(를) 초과하지 않아야 함).
%utils.move_specific_files_from_dir(target_dir, dest_dir, regexp);

% target_file_list = dir(target_dir);
% for i=1:length(target_file_list)
%     filename = target_file_list(i).name;
%     if length(filename) > 8
%         filename
%         
%         k = regexp(filename, '[\d*]+_+\S+.nii')
%         if k==1
%             disp('done')
%         end
%     end
% end


