function [] = AppB_Compute_profiles()
%% 
% 1 - Generate nifti with prdiction of signal given the pair of tracts CST_L and SLF_L
% 2 - Use VITASOFT to compute FA on predictions


%% Rrequisites:
% This step requires a model fit to data and saved as a fe-structure and a proper defined function subject_info_int()
% containing all settings for a given subject (paths, parameters, etc.)

%% Initialize subject info
info = subject_info_init(); 
%% Set the proper path for VISTASOFT 
addpath(genpath(info.repo.vistasoft));
%% Set the proper path for the ENCODE
addpath(genpath(info.repo.encode_local));

%% paths
data_out_path = fullfile(info.output.niftis);
if ~(exist(data_out_path,'dir'))
    mkdir(data_out_path);
end 

%% 1- Generate predictions
Gen_niftis_crossing_tracts(info, 'CST_L', 'SLF_L')

%% 2- Comute FAs using VISTASOFT
listing = dir(strcat(data_out_path,'/',info.name_base,'*.nii.gz'));
Nfiles = size(listing,1);
%cd(data_out_path)
dwiFile = info.input.dwi_path;
bvecsFile = strcat(dwiFile(1:end-6),'bvecs');
bvalsFile = strcat(dwiFile(1:end-6),'bvals');    
bs.n = 500;
[bs.permuteMatrix, ~, ~] = ...
    dtiBootGetPermMatrix(dlmread(bvecsFile),dlmread(bvalsFile));
bs.showProgress = false;

% nifti for reference
ni = niftiRead(dwiFile);
for n=1:Nfiles
    dwRawAligned = fullfile(info.output.niftis,listing(n).name);
    %% Using Mex file
    [dt6FileName]= dtiRawFitTensorMex(dwRawAligned, bvecsFile,...
        bvalsFile, data_out_path,bs,[],'ls', [], [], 1);
    dt = dtiLoadDt6(dt6FileName);
    val_dt6 = dt.dt6;
    [nil, eigVal] = dtiSplitTensor(val_dt6);
    val1 = dtiComputeFA(eigVal);

    
    %% Generate nifti with FA values
    name = fullfile(info.output.niftis,strcat('FA_',listing(n).name));
    
    ni_out = ni;
    ni_out.fname = name;
    ni_out.dim = size(val1);
    ni_out.data = val1;
    niftiWrite(ni_out,name);
end






end