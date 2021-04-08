
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




target_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Hammers_mith_atlas_n30r83_delivery_Dec16';
atlas_filename = 'Hammers_mith_atlas_n30r83_SPM5_2mm_79_95_68.nii';
save_filename = 'Hammers_WholeBrain_2mm_79_95_68.nii';
full_path = strcat(target_dir, '\', atlas_filename);
save_path = strcat(target_dir, '\', save_filename);
nii = load_nii(full_path)
% nii.img(nii.img==17)=100 % for Cerebellum_L
% nii.img(nii.img==18)=100 % for Cerebellum_R
% nii.img(nii.img==19)=100 % for BrainStem
% for whole brain
nii.img(nii.img==19)=100
nii.img(nii.img==2)=100
nii.img(nii.img==20)=100
nii.img(nii.img==21)=100
nii.img(nii.img==22)=100
nii.img(nii.img==23)=100
nii.img(nii.img==24)=100
nii.img(nii.img==25)=100
nii.img(nii.img==26)=100
nii.img(nii.img==27)=100
nii.img(nii.img==28)=100
nii.img(nii.img==29)=100
nii.img(nii.img==3)=100
nii.img(nii.img==30)=100
nii.img(nii.img==31)=100
nii.img(nii.img==32)=100
nii.img(nii.img==33)=100
nii.img(nii.img==34)=100
nii.img(nii.img==35)=100
nii.img(nii.img==38)=100
nii.img(nii.img==39)=100
nii.img(nii.img==4)=100
nii.img(nii.img==40)=100
nii.img(nii.img==41)=100
nii.img(nii.img==44)=100
nii.img(nii.img==5)=100
nii.img(nii.img==50)=100
nii.img(nii.img==51)=100
nii.img(nii.img==52)=100
nii.img(nii.img==53)=100
nii.img(nii.img==54)=100
nii.img(nii.img==55)=100
nii.img(nii.img==56)=100
nii.img(nii.img==57)=100
nii.img(nii.img==58)=100
nii.img(nii.img==59)=100
nii.img(nii.img==6)=100
nii.img(nii.img==60)=100
nii.img(nii.img==61)=100
nii.img(nii.img==62)=100
nii.img(nii.img==63)=100
nii.img(nii.img==64)=100
nii.img(nii.img==65)=100
nii.img(nii.img==66)=100
nii.img(nii.img==67)=100
nii.img(nii.img==68)=100
nii.img(nii.img==69)=100
nii.img(nii.img==7)=100
nii.img(nii.img==70)=100
nii.img(nii.img==71)=100
nii.img(nii.img==72)=100
nii.img(nii.img==73)=100
nii.img(nii.img==74)=100
nii.img(nii.img==75)=100
nii.img(nii.img==76)=100
nii.img(nii.img==77)=100
nii.img(nii.img==78)=100
nii.img(nii.img==79)=100
nii.img(nii.img==8)=100
nii.img(nii.img==80)=100
nii.img(nii.img==81)=100
nii.img(nii.img==82)=100
nii.img(nii.img==83)=100
nii.img(nii.img==9)=100

nii.img(nii.img<100)=0
nii.img(nii.img==100)=1
save_nii(nii, save_path);



% option.cut_from_L = 6; % x
% option.cut_from_R = 6; % x
% option.cut_from_P = 7; % y rear
% option.cut_from_A = 7; % y front
% option.cut_from_I = 11; % z bottom
% option.cut_from_S = 12; % z top
% option
% clipped_nii = clip_nii(nii, option);
% save_nii(clipped_nii, save_path);

% old_fn = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test_CT_TO_PET_coreg_ex\CT\kkk.nii'
% new_fn = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Dy_PET_SUV\small_set_test_CT_TO_PET_coreg_ex\CT\resliced_cropped_36361.nii'
% voxel_size = [2, 2, 2]
% reslice_nii(old_fn, new_fn, voxel_size)
