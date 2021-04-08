%target_dir1 = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201221\input\3_CN\\total_mean_0to20min_match_norm_cnt_CN_CbGM_FBB.nii';
target_dir1 = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201222\2_CN\2_CN_CbGM\total_2to7min_FBB_match_norm_cnt.nii';
target_dir2 = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\results\201222\2_CN\2_CN_CbGM\total_static_FDG_match_norm_cnt.nii';

%mask_img_dir = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\datas\masks\GM(shj)\mask_grey_above05.nii';
mask_img_dir = 'C:\Users\hkang\hyeon\협력 연구원 협조\신현지 연구원\paper_work\datas\masks\WB_AAL_GM(shj)\AAL3v1_WholdBrain_GMmask(shj).nii';
mask_img_dir=0
nii1 = load_nii(target_dir1);
nii2 = load_nii(target_dir2);

nii1_img = nii1.img;
nii2_img = nii2.img;

if mask_img_dir ~= 0
    mask_nii = load_nii(mask_img_dir);
    mask_nii_img = mask_nii.img;
    nii1_img = nii1_img.*double(mask_nii_img);
    nii2_img = nii2_img.*double(mask_nii_img);
    
    nii1_img = nii1_img(nii1_img~=0);
    nii2_img = nii2_img(nii2_img~=0);
end

size(nii1_img)
size(nii2_img)

[R, P]=corrcoef(nii1_img, nii2_img)
