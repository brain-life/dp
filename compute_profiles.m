function [] = compute_profiles()

if ~isdeployed
    %addpath(genpath('/home/hayashis/git/encode'));
    addpath(genpath('./encode'));
    addpath(genpath('/home/hayashis/git/vistasoft'));
    addpath(genpath('/home/hayashis/git/mba'))
    addpath(genpath('/home/hayashis/git/jsonlab'));

    addpath(genpath('/N/u/brlife/git/vistasoft'));
    addpath(genpath('/N/dc2/projects/lifebid/code/mba/')) %needed for cesar
    addpath(genpath('/N/u/brlife/git/jsonlab'));
end

%following is needed to tell mcc compiler that we need to include sptensor even though we
%don't reference it anywhere in the code
%# function sptensor

config = loadjson('config.json')

disp('loading dt6.mat')
dt6 = loadjson(fullfile(config.dtiinit, 'dt6.json'))
aligned_dwi = fullfile(config.dtiinit, dt6.files.alignedDwRaw)
bvecsFile = strcat(aligned_dwi(1:end-6),'bvecs');
bvalsFile = strcat(aligned_dwi(1:end-6),'bvals');    

info = struct;
info.segmentation_type = 'AFQ'; % In the future we could use a more complete segmentation (more than 20 major tracts)
info.input = struct;
info.input.dwi_path = aligned_dwi;
info.input.classification_path = config.afq;
info.input.optimal = config.optimal;
info.output = struct;
info.output.niftis = 'output';
tract1_L = 'CST_L';
tract2_L = 'SLF_L';
tract1_R = 'CST_R';
tract2_R = 'SLF_R';

disp('step 1 - Generate nifti with prdiction of signal given the pair of tracts CST and SLF')
mkdir('output');
other_tracts_L = {'ARC_L','Thal_Rad_L'};
Gen_niftis_crossing_tracts(info, tract1_L, tract2_L, other_tracts_L)
other_tracts_R = {'ARC_R','Thal_Rad_R'};
Gen_niftis_crossing_tracts(info, tract1_R, tract2_R, other_tracts_R)

disp('step 2 - Use VITASOFT to compute FA, MD, RD, AD on predictions')
listing = dir(strcat('output/*.nii.gz'));
Nfiles = size(listing,1);
bs.n = 500;
[bs.permuteMatrix, ~, ~] = dtiBootGetPermMatrix(dlmread(bvecsFile),dlmread(bvalsFile));
bs.showProgress = false;
ni = niftiRead(aligned_dwi);
mkdir('output/FAs')
mkdir('output/MDs')
mkdir('output/RDs')
mkdir('output/ADs')
for n=1:Nfiles
    dwRawAligned = fullfile('output',listing(n).name);
    data_out_path = fullfile(info.output.niftis);
    [dt6FileName]= dtiRawFitTensorMex(dwRawAligned, bvecsFile, bvalsFile, data_out_path, bs,[],'ls', [], [], 1);
    dt = dtiLoadDt6(dt6FileName);
    val_dt6 = dt.dt6;
    [nil, eigVal] = dtiSplitTensor(val_dt6);
    

    %% Generate nifti with FA values
    [fa_val, md_val, rd_val, ad_val] = dtiComputeFA(eigVal);
    name = fullfile('output/FAs',strcat('FA_',listing(n).name));
    ni_out = ni;
    ni_out.fname = name;
    ni_out.dim = size(fa_val);
    ni_out.data = fa_val;
    niftiWrite(ni_out,name);
    
    %% Generate nifti with MD values
    name = fullfile('output/MDs',strcat('MD_',listing(n).name));
    ni_out = ni;
    ni_out.fname = name;
    ni_out.dim = size(md_val);
    ni_out.data = md_val;
    niftiWrite(ni_out,name);
    
    %% Generate nifti with RD values
    name = fullfile('output/RDs',strcat('RD_',listing(n).name));
    ni_out = ni;
    ni_out.fname = name;
    ni_out.dim = size(rd_val);
    ni_out.data = rd_val;
    niftiWrite(ni_out,name);
    
    %% Generate nifti with AD values
    name = fullfile('output/ADs',strcat('AD_',listing(n).name));
    ni_out = ni;
    ni_out.fname = name;
    ni_out.dim = size(ad_val);
    ni_out.data = ad_val;
    niftiWrite(ni_out,name);    
end

disp('3- Compute and plot profiles');
mkdir('results');
% FA
Gen_tract_profiles_pair(info, tract1_L, tract2_L, 10, 'FA')
Gen_tract_profiles_pair(info, tract1_R, tract2_R, 10, 'FA')
% MD
Gen_tract_profiles_pair(info, tract1_L, tract2_L, 10, 'MD')
Gen_tract_profiles_pair(info, tract1_R, tract2_R, 10, 'MD')
% RD
Gen_tract_profiles_pair(info, tract1_L, tract2_L, 10, 'RD')
Gen_tract_profiles_pair(info, tract1_R, tract2_R, 10, 'RD')
% AD
Gen_tract_profiles_pair(info, tract1_L, tract2_L, 10, 'AD')
Gen_tract_profiles_pair(info, tract1_R, tract2_R, 10, 'AD')

end
