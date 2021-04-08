AAL3v1_nii_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\AAL3\AAL3v1.nii';
nii_file_save_dir = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\AAL3\each_vol_mask'; 
AAL3_xml_file_path = 'C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\AAL3\AAL3v1.xml';

% nii_path(strfind(nii_path, '\')) = '/';
% 


% %flip_lr(nii_file_path, 'flipped_output.nii');
% test_nii.img(test_nii.img~=1)=0;
% %size(test_nii) % 91*109*91
% 
% %[S, L] = bounds(test_nii, 'all');
% %S % 0
% %L % 170
% 
% 
% 
% % test_nii = [1, 0, 2;2, 0, 1; 2, 2, 2];
% % test_nii2 = test_nii
% % test_nii2(test_nii2<1 | test_nii2>1)=3;
% % test_nii2(test_nii2~=0)=3;
% 
% % save revised nii file
% save_nii(test_nii, nii_file_save_path)

% handling xml data
% DOMnode = xmlread(AAL3_xml_file_path);
% type(AAL3_xml_file_path)

aalv3_nii = load_nii(AAL3v1_nii_path);
aalv3_nii
AAL3_xmlfile = parseXML(string(AAL3_xml_file_path));
for i=1:166
    
%     num_voxels = sum(aalv3_nii.img(:) == i);
%     num_voxels
    

    num_region=i;
    region_cidx = AAL3_xmlfile.Children(4).Children(num_region*2).Children(1).Children.Data;
    region_name = AAL3_xmlfile.Children(4).Children(num_region*2).Children(2).Children.Data;
    region_idx = str2num(region_cidx);
    %num_region
    %region_idx
    
    num_voxels = sum(aalv3_nii.img(:) == region_idx);
    num_voxels
    
    if num_voxels~=0
        region_idx
        class(region_idx)
        % region_idx
        % region_name
        save_path = strcat(nii_file_save_dir, '\', region_cidx, '_', region_name, '.nii');
        % save_path
        
        %tmp_aalv3_nii = aalv3_nii;
        tmp_aalv3_nii_hdr = aalv3_nii.hdr
        tmp_aalv3_nii_fileprefix = strcat('C:\Users\hkang\MatlabProjects\SPM\spm12\spm12\custom_modules\test_dir\AAL3\each_vol_mask', '\', region_cidx, '_', region_name)
        tmp_aalv3_nii_voxel_size=size(aalv3_nii.img);
        tmp_aalv3_nii_origin=aalv3_nii.hdr.hist.originator(1:3);
        tmp_aalv3_nii_img = aalv3_nii.img;
        % size(tmp_aalv3_nii_img)
        %tmp_aalv3_nii.img(aalv3_nii.img==region_idx)=1;
        %tmp_aalv3_nii.img(aalv3_nii.img~=region_idx)=0;
        
        tmp_aalv3_nii_img(aalv3_nii.img==region_idx)=1;
        tmp_aalv3_nii_img(aalv3_nii.img~=region_idx)=0;
        num_voxels = sum(tmp_aalv3_nii_img(:) == 1);
        num_voxels
        
        if num_voxels~=0
            res_nii = make_nii(tmp_aalv3_nii_img, tmp_aalv3_nii_voxel_size, tmp_aalv3_nii_origin, 2)
            save_nii(res_nii, save_path)
        end
    end
    
    
end
% aalv3_nii = load_nii(AAL3v1_nii_path);
% aalv3_nii
% num_voxels = sum(aalv3_nii.img(:) ~= uint8(2));
% num_voxels
% num_region=i;
% region_cidx = AAL3_xmlfile.Children(4).Children(num_region*2).Children(1).Children.Data;
% region_name = AAL3_xmlfile.Children(4).Children(num_region*2).Children(2).Children.Data;
% region_idx = str2num(region_cidx);
% num_region
% region_idx

    
