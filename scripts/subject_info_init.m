function [info] = subject_info_init()
%% Basic info
info.dataset = 'HCP3T'; % Dataset
info.id = '105115'; % subject ID
info.tractography_type = 'PROB'; % Should be consistent with info.input.fg_path and info.input.classification_path (see below)
info.segmentation_type = 'AFQ'; % In the future we could use a more complete segmentation (more than 20 major tracts)
info.name_base = strcat(info.dataset,'_',info.id,'_',info.tractography_type); % name base for output files

%% Model general parameters
info.parameters.L = 45;     % Number of discretization steps in spherical coordinates
info.parameters.p = 0.5;    % percentage of training gradient directions (50% training and 50% testing)
info.parameters.n = 0.05;    % 0.01;   % percentage of voxels used for crossvalidation. Ideally, we will want to fit using the 100% of tract voxels
                            % but we could reduce that percentange after we look at the results of experiments currently going on to see to 
                            % what extent we will be able to reduce the number of voxels safely.
                            % For testing the code it is suggested to use, for example, only 1% of voxels (0.01)
info.parameters.m = 0.05;    % percentage of fibers used for crossvalidation.
                       

%% GRID-SEARCH definition: Here we define an ideal space search defining a grid with a total of  19*7*5 = 665 points
% For testing purposes, we suggest to reduce the number of points by
% subsampling the set of points defined below for alpha_v, lambda_1 and lambda_2
info.parameters.alpha_v = [2,4,8];%0:0.4:7.5;                                % [0, 4, 7 ]  % 19 points
info.parameters.alpha_f = 0;                                        % parameter set to zero always
info.parameters.lambda_1 = [1.5,2];%[1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5];  %[1.0, 1.5, 2.0]; % 7 points
info.parameters.lambda_2 = [0,0.2];%[0, 0.05, 0.1, 0.15, 0.2];               %[0, 0.1, 0.2]; % 5 points

%% Random seed
info.parameters.seed = sum(100*clock);

%% Repositories Paths
info.repo.encode_local = '../encode'; % This is a local version of encode (is not the same of https://github.com/brain-life/encode)
info.repo.vistasoft = '/N/dc2/projects/lifebid/code/vistasoft/'; % This is standard vistasoft (https://github.com/vistalab/vistasoft)
info.repo.mba = '/N/dc2/projects/lifebid/code/mba/'; % This is standard mba (https://github.com/mba)
%% Input data paths
info.input.dwi_path = '../data/diffusion_data/dwi_data_b2000_aligned_trilin.nii.gz'; % path to diffusion signal
info.input.fg_path = '../data/tractography/dwi_data_b2000_aligned_trilin_csd_lmax10_wm_SD_PROB-NUM01-500000.tck'; % probabilistic tractography
info.input.classification_path = '../data/classification/fe_structure_105115_STC_run01_500000_SD_PROB_lmax10_connNUM01_TRACTS-nocull.mat'; % probabilistic tractography

%% Output data path
info.output.results_root = '../results';
info.output.niftis = '../results/niftis';

end
