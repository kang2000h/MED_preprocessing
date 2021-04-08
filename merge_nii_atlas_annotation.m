nii_atlas_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Hammers_mith_atlas_n30r83_delivery_Dec16\Hammers_mith_atlas_n30r83_SPM5_2mm_79_95_68.nii';
json_label_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\Hammers_mith_atlas_n30r83_delivery_Dec16\merged_region_idx\Hammers_merged_n30r83_ver3.0_200806.json';
output_filename = 'Merged_Hammers_mith_atlas_n30r83_SPM5_2mm_79_95_68_200828';

save_merged_nii_atlas_changed_annotation(nii_atlas_path, json_label_path, output_filename)

function save_merged_nii_atlas_changed_annotation(nii_atlas_path, json_label_path, output_filename)
    voi_nii = load_nii(nii_atlas_path);
    ori_voi_size = size(voi_nii.img);
    
    [voi_mask_name_list, voi_matrice] = get_voi_mask(nii_atlas_path, json_label_path, 0, 0);
    len_voi_mask_name_list = length(voi_mask_name_list) % 79
    len_voi_matrice = length(voi_matrice) % 79
    regional_voi_matrice = zeros(ori_voi_size);
    json_key_name_list = [] % name of target region
    json_value_list = [] % index
    for i = 1:length(voi_matrice);
        mat=voi_matrice{i};
        sp = sum(mat(:));
        mat(mat>0)=i;
        regional_voi_matrice = regional_voi_matrice+double(mat);
        %class(mat)
        %max(mat(:))
        json_key_name_list = [json_key_name_list, string(voi_mask_name_list{i})];
        json_key_name_list
        json_value_list = [json_value_list, i];
        json_value_list
    end    
    max(regional_voi_matrice(:))
    [nii_atlas_dirpath, ~] = fileparts(nii_atlas_path);
    nii_atlas_dirpath
    
    % save merged nii file
    save_path = strcat(nii_atlas_dirpath, '\', output_filename, '.nii');
    save_path
    voi_nii.img = regional_voi_matrice;
    save_nii(voi_nii, save_path);
    % save json file
    json_filename =  strcat(nii_atlas_dirpath, '\', output_filename, '.json');
    

%     for i=1:length(json_key_name_list) 
%         
%         myFunction
%         
%     end
    s = myFunction(json_value_list, json_key_name_list);
    saveJSONfile(s, json_filename);
end
 
function outStruct = myFunction(values, fieldNames)
    for i=1:length(fieldNames);
        outStruct.(fieldNames(i)) = values(i) ;
    end
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
            if sum(tmp_mat(:))==0
                continue
%             else 
%                 sumof_tmp_mat = sum(tmp_mat(:));
%                 sumof_tmp_mat
            end
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
            regional_voi_matrice = additional_mask.img.*regional_voi_matrice;
            
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