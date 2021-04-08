% input_filedir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\6_CT_driven dPET_template_based_registration\2_count_match_PET';
% voi_nii_filepath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Hammers_mith_atlas_n30r83_delivery_Dec16\Hammers_mith_atlas_n30r83_SPM5_2mm_79_95_68.nii';
% voi_label_json_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Hammers_mith_atlas_n30r83_delivery_Dec16\merged_region_idx\Hammers_merged_n30r83_ver3.0_200806.json';
% save_filepath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\4_MR_based_registration_experiment\6_CT_driven dPET_template_based_registration\3_VOI_byCB';
% 
% mask_savepath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Hammers_mith_atlas_n30r83_delivery_Dec16\merged_region_idx\output_mask_ver3.0';
% mask_savepath = 0
% gm_mask = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Clinical_\scgrey_79_95_68.nii' ;
% %gm_mask =0    
% measure = 'mean'

% input_filedir = 'E:\SHJ\2_2_FDG_cnt67';
% voi_nii_filepath = 'E:\SHJ\mask_grey_above05.nii';
% voi_label_json_path = 'E:\SHJ\mask_grey_above05.json';
% save_filepath = 'E:\SHJ\5_CompositeSUVr\2_FDG';
% 
% mask_savepath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Hammers_mith_atlas_n30r83_delivery_Dec16\merged_region_idx\output_mask_ver3.0';
% mask_savepath = 0
% gm_mask = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Clinical_\scgrey_79_95_68.nii' ;
% gm_mask =0    
% measure = 'mean'

%% AAL and GM masking (shj)
input_filedir = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201223\6_baseline_time_comp\2_CN';
voi_nii_filepath = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\AAL3\AAL3v1.nii';
voi_label_json_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\AAL3\merged_region_idx\AAL_merged_ver1.0_200730.json';
save_filepath = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201223\6_baseline_time_comp\3_SUVr';

mask_savepath = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201211\SUVr\5_masks';
mask_savepath=0
gm_mask = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\datas\masks\GM(shj)\mask_grey_above05.nii' ;
%gm_mask=0
measure = 'mean'

get_regional_activity_on_VOI_on_batch(input_filedir, voi_nii_filepath, voi_label_json_path, save_filepath, gm_mask, mask_savepath, measure)
function get_regional_activity_on_VOI_on_batch(input_dir, voi_nii_filepath, json_label_path, save_filepath, gm_mask, mask_savepath, measure)
    % input_filepath_list = dir(input_dir)
    input_filepath_list = dir(strcat(input_dir,'\', '*.nii'));
    
    for i=1:length(input_filepath_list)
        target_input_filepath = strcat(input_dir, '\', input_filepath_list(i).name);
        if endsWith(target_input_filepath, '.nii') % && ~startsWith(target_input_filepath, 'count_')
            get_regional_activity_on_VOI_on_sample(target_input_filepath, voi_nii_filepath, json_label_path, save_filepath, gm_mask, mask_savepath, measure)
        end
    end
end

%get_regional_activity_on_VOI_on_sample(input_filepath, voi_nii_filepath, json_label_path, save_filepath, gm_mask, mask_savepath)

% Input : input_filepath, region_ind_matching_filepath,
% use_gray_mask, use_white_mask
% Output : csv file including regional activity, Frame(Col)*Regions(Row)
% when using masking, the applied region need to be annotated like frontal_G, frontal_W
function get_regional_activity_on_VOI_on_sample(input_filepath, voi_nii_filepath, json_label_path, save_filepath, add_mask, mask_savepath, measure)
    %target_nii = load_nii(input_filepath)
    
    [voi_mask_name_list, voi_matrice] = get_voi_mask(voi_nii_filepath, json_label_path, add_mask, mask_savepath);
%     voi_mask_name_list
%     voi_matrice
    
    rowNames = {};
    colNames = {};
    suv_board = [];
    input_nii = load_nii(input_filepath);
    for fr_i=1:size(input_nii.img, 4)
        target_nii_img = input_nii.img(:,:,:,fr_i);
        colNames{fr_i} = int2str(fr_i);
            regional_suv_on_fr = [];
            for v_i=1:numel(voi_mask_name_list)
                if fr_i==1
                    rowNames{v_i} = voi_mask_name_list{v_i};
                end
                tmp_mat = voi_matrice{v_i};
                masked_region = target_nii_img.*voi_matrice{v_i};
                if strcmp(measure, 'mean') % measure == 'mean'
                    %mean_suv = mean(masked_region(masked_region~=0));
                    %mean_suv 
                    %sum(masked_region, 'all')
                    %sum(tmp_mat, 'all')
                    mean_suv = sum(masked_region, 'all')/sum(tmp_mat, 'all')
                    regional_suv_on_fr = [regional_suv_on_fr;mean_suv];
                elseif strcmp(measure, 'median') % measure== 'median'
                    median_suv = median(masked_region(masked_region~=0));
                    regional_suv_on_fr = [regional_suv_on_fr;median_suv];
                end
                
            end
            suv_board = [suv_board, regional_suv_on_fr];
    end 
    
    % Writing Matrix
    tacTable = array2table(suv_board,'RowNames',rowNames,'VariableNames',colNames);
    [filedir, filename] = fileparts(input_filepath);
    save_path = strcat(save_filepath, '\', filename, '.csv') ;
    writetable(tacTable, save_path,'WriteRowNames',true);

end

function [voi_mask_name_list, voi_matrice] = get_voi_mask(voi_nii_path, voi_json_label_path, add_mask, mask_savepath)
    voi_nii = load_nii(voi_nii_path);
    ori_voi_size = size(voi_nii.img);
    % read json label file
    fid = fopen(voi_json_label_path,'r');
    json_str = fscanf(fid, "%s");
    json_struct = parse_json(json_str);
    fclose(fid);
    
    json_struct = json_struct{1};
    json_fd_name = fieldnames(json_struct);
    
%     voi_mask_struct.label_name=[]
%     for i=1:length(json_fd_name)
%         fd_cell = json_fd_name(i);
%         voi_label_name = fd_cell{1};
%         % extract label name
%         voi_mask_struct.label_name = [voi_mask_struct.label_name, string(voi_label_name)];
%         json_struct;
%         
%         
%         % extract mask
%         
%     end    
    
    voi_mask_name_list = [];
    voi_matrice = [];
    for i=1:numel(json_fd_name)
        if add_mask==0
            origin_i = i;
            addmask_i = 0;
        else 
            origin_i = 2*(i-1)+1;
            addmask_i = 2*i;
        end
        cell_list = json_struct.(json_fd_name{i});
        
        regional_voi_matrice = zeros(ori_voi_size);
        
        for j=1:length(cell_list)
            tmp_mat=voi_nii.img;
            voi_ind = cell_list{j};
            tmp_mat(tmp_mat~=voi_ind)=0;
            tmp_mat(tmp_mat==voi_ind)=1;
            
            regional_voi_matrice = regional_voi_matrice+double(tmp_mat);
        end
        
        
        voi_mask_name_list{origin_i} = json_fd_name{i};
        voi_matrice{origin_i} = regional_voi_matrice;
        
        if mask_savepath ~=0
            [filedir, filename]= fileparts(voi_nii_path);
            final_mask_savepath = strcat(mask_savepath, '\', json_fd_name{i}, '_', filename, '.nii');

            tmp_nii = voi_nii;
            tmp_nii.img = regional_voi_matrice;
            save_nii(tmp_nii, final_mask_savepath);
        end
       
        % additional masking
        if add_mask~=0
            additional_mask =load_nii(add_mask);
           
            regional_voi_matrice = double(additional_mask.img).*regional_voi_matrice;
            
            voi_mask_name_list{addmask_i} = strcat(json_fd_name{i}, '_ADDMASK');
            voi_matrice{addmask_i} = regional_voi_matrice;
            
            if mask_savepath ~=0
                [filedir, filename]= fileparts(voi_nii_path);
                final_mask_savepath = strcat(mask_savepath, '\', json_fd_name{i},'_ADDMASK_', filename, '.nii');

                tmp_nii = voi_nii;
                tmp_nii.img = regional_voi_matrice;
                save_nii(tmp_nii, final_mask_savepath);
            end
        
        end
    end
end