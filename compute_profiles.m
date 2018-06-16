function [] = compute_profiles()
%% 
% 1 - Generate nifti with prdiction of signal given the pair of tracts CST_L and SLF_L
% 2 - Use VITASOFT to compute FA on predictions


if ~isdeployed
    %addpath(genpath('/home/hayashis/git/encode'));
    addpath(genpath('./encode'));
    addpath(genpath('/home/hayashis/git/vistasoft'));
    addpath(genpath('/N/dc2/projects/lifebid/code/mba/'))
    addpath(genpath('/home/hayashis/git/jsonlab'));
end

%# function sptensor

mkdir('output');
config = loadjson('config.json')

disp('loading dt6.mat')
dt6 = loadjson(fullfile(config.dtiinit, 'dt6.json'))
aligned_dwi = fullfile(config.dtiinit, dt6.files.alignedDwRaw)
bvecsFile = strcat(aligned_dwi(1:end-6),'bvecs');
bvalsFile = strcat(aligned_dwi(1:end-6),'bvals');    

%% 1- Generate predictions
info = struct;
info.segmentation_type = 'AFQ'; % In the future we could use a more complete segmentation (more than 20 major tracts)
info.input = struct;
info.input.dwi_path = aligned_dwi;
info.input.classification_path = config.afq;
info.input.optimal = config.optimal;
info.output = struct;
info.output.niftis = 'output';
info.output.results_root = 'output';
bvals = dlmread(bvalsFile);

data_out_path = fullfile(info.output.niftis);

tract1 = 'CST_L';
tract2 = 'SLF_L';
other_tracts = {'ARC_L','Thal_Rad_L'};

Gen_niftis_crossing_tracts(info, tract1, tract2, other_tracts)

%% 2- Comute FAs using VISTASOFT
listing = dir(strcat('output/*.nii.gz'));
Nfiles = size(listing,1);
bs.n = 500;
[bs.permuteMatrix, ~, ~] = dtiBootGetPermMatrix(dlmread(bvecsFile),dlmread(bvalsFile));
bs.showProgress = false;

ni = niftiRead(aligned_dwi);
for n=1:Nfiles
    dwRawAligned = fullfile('output',listing(n).name);
    [dt6FileName]= dtiRawFitTensorMex(dwRawAligned, bvecsFile, bvalsFile, data_out_path, bs,[],'ls', [], [], 1);
    dt = dtiLoadDt6(dt6FileName);
    val_dt6 = dt.dt6;
    [nil, eigVal] = dtiSplitTensor(val_dt6);
    val1 = dtiComputeFA(eigVal);

    %% Generate nifti with FA values
    name = fullfile('output',strcat('FA_',listing(n).name));
    
    ni_out = ni;
    ni_out.fname = name;
    ni_out.dim = size(val1);
    ni_out.data = val1;
    niftiWrite(ni_out,name);
end

%% 3- Compute and plot profiles
Gen_tract_profiles_pair(info, tract1, tract2, 10)

end
