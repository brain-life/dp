function [] = remove_tracts_from_prediction()

if ~isdeployed
    %addpath(genpath('/home/hayashis/git/encode'));
    addpath(genpath('./encode'));
    addpath(genpath('/home/hayashis/git/vistasoft'));
    addpath(genpath('/home/hayashis/git/mba'))
    addpath(genpath('/home/hayashis/git/jsonlab'));

    %needed for cesar
    addpath(genpath('/N/dc2/projects/lifebid/code/mba/'))
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

copyfile(bvecsFile, 'dwi.bvecs');
copyfile(bvalsFile, 'dwi.bvals');

info = struct;
info.segmentation_type = 'AFQ'; % In the future we could use a more complete segmentation (more than 20 major tracts)
info.input = struct;
info.input.dwi_path = aligned_dwi;
info.input.classification_path = config.afq;
info.input.optimal = config.optimal;
info.input.profile = config.profile;
% Tracts to remove
tracts = {'ARC_L', 'SLF_L', 'ARC_R', 'SLF_R'} ;

Gen_niftis_remove_tracts(info, tracts)

end
