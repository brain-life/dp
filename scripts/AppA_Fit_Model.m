function [] = AppA_Fit_Model()
% Requisites:
% - subject_info_init.m function available in the same folder including all
% important definitions for the experiment.


% Initialize subject info
info = subject_info_init(); 

% check if results folder exists, if not, it is created
data_out_path = fullfile(info.output.results_root);
if ~(exist(data_out_path,'dir'))
    mkdir(data_out_path);
end 

% Set the proper path for the ENCODE
addpath(genpath(info.repo.encode_local));
% Set the proper path for VISTASOFT 
addpath(genpath(info.repo.vistasoft));

% Build the file names for the diffusion data and tractography. Set input
% parameters
dwiFile       = fullfile(info.input.dwi_path); % diffusion data file
fgFileName    = fullfile(info.input.fg_path); % tractography file
feFileName    = info.name_base;  % file name for output
L = info.parameters.L; % Discretization parameter
p = info.parameters.p; % Training data proportion
n = info.parameters.n; % voxel subsampling
m = info.parameters.m; % fibers subsampling
alpha_f = 0;

%% STEP 1: Grid search fitting the model for a different set of parameters
Ncases = length(info.parameters.alpha_v)*length(info.parameters.lambda_1)*length(info.parameters.lambda_2);
Time = zeros(Ncases,1);
% HERE we fit the model for each point in the space of parameters in a
% nested loop which needs to be parallelized in Brain Life, i.e. by
% computing each point of the grid in parallel (665 parallel computations)
i = 1;
for alpha_v = info.parameters.alpha_v
    for lambda_1 = info.parameters.lambda_1
        for lambda_2 = info.parameters.lambda_2
            rng(info.parameters.seed); % seed used for random selection of voxels (same seed for same experiment)
            
            % Fit the model in a single point in the space of parameters.
            tic
            %[~, results] = FitFullModelSampleAllTracts(dwiFile, fgFileName, feFileName, L, p, n, alpha_v, alpha_f, lambda_1, lambda_2, info.input.classification_path);
            [~, results] = FitFullModelSampleVoxels_and_Fibers(dwiFile, fgFileName, feFileName, L, p, n, m, alpha_v, alpha_f, lambda_1, lambda_2, info.input.classification_path);
            Time(i) = toc/60; % Time in minutes
            
            disp(' ');
            disp(['Case ', num2str(i),'/',num2str(Ncases),' (alpha_v, lambda_, lambda_2)=(',num2str(alpha_v),',',num2str(lambda_1),',',num2str(lambda_2),')', ...
                ', Took=', num2str(Time(i)), 'mins']);
            
            % save results to disk
            fileName = fullfile(info.output.results_root, strcat('results_',feFileName,'_alpha_v_',num2str(alpha_v),'_alpha_f_',num2str(alpha_f), ...
                '_lambda_1_',num2str(lambda_1),'_lambda_2_',num2str(lambda_2),'.mat'));
            save(fileName, 'results','-v7.3')
            i = i + 1;
        end
    end
end

disp(' ')
disp(['GRID SEARCH finished. Average Time per grid point:', num2str(mean(Time)), ' mins, using ', num2str(100*n), '% of voxels'])
disp(' ')

%% STEP 2: Final model fitting

% Find optimal values of parameters
[alpha_v, lambda_1, lambda_2, ~] = Get_surface_grid_search(info.output.results_root);

% Fit Full Model using optimal parameters and 100% of gradient directions
tic
[fe, results] = FitFullModel(dwiFile, fgFileName, feFileName, L, n, alpha_v, alpha_f, lambda_1, lambda_2);         

TimeFullFit = toc/60;

disp(['Time Fitting Full Model=',num2str(TimeFullFit),'mins'])

%% Saving output results
disp('SAVING RESULTS...')
save(fullfile(info.output.results_root,strcat(feFileName,'_alpha_v_',num2str(alpha_v),'_alpha_f_',num2str(0),...
'_lambda_1_',num2str(lambda_1),'_lambda_2_',num2str(lambda_2),'.mat')), 'fe','-v7.3')

info.parameters.opt.alpha_v = alpha_v;
info.parameters.opt.alpha_f = 0;
info.parameters.opt.lambda_1 = lambda_1;
info.parameters.opt.lambda_2 = lambda_2;
info.fit = results;
name = strcat('info_',info.name_base,'.mat');
save(fullfile(info.output.results_root,name), 'info');

rmpath(info.repo.encode_local);
rmpath(info.repo.vistasoft);
end

%% Function that read all 
function [alpha_v_min, lambda_1_min, lambda_2_min, error] = Get_surface_grid_search(dataInputPath)
listing = dir(strcat(dataInputPath,'/results*.mat'));
Nfiles = size(listing,1);
for n=1:Nfiles
    disp(['reading file ',num2str(n),'/',num2str(Nfiles)])
    load(strcat(dataInputPath,'/',listing(n).name));
    error.alpha_v(n) = results.alpha_v;
    error.lambda_1(n) = results.lambda_1;
    error.lambda_2(n) = results.lambda_2;
    error.value(n) = results.Error_val;
end

[~, ind] = min(error.value); % search for the minimum validation error
alpha_v_min = error.alpha_v(ind);
lambda_1_min = error.lambda_1(ind);
lambda_2_min = error.lambda_2(ind);

plotOptimizationSurface(error, alpha_v_min, lambda_1_min, lambda_2_min)
end

%% 
function [] = plotOptimizationSurface(error, alpha_v, lambda_1, lambda_2)

%% plot alpha_v profile
figure
set(gcf,'units','points','position',[200,400,800,200])
hold on
ind2 = find(error.lambda_1 == lambda_1);
ind3 = find(error.lambda_2 == lambda_2);
subplot(1,3,1)
scatter(error.alpha_v(intersect(ind2,ind3)), error.value(intersect(ind2,ind3)))
% Create xlabel
xlabel('\alpha_v');

% Create ylabel
ylabel('Error');

%% plot lambda_1 profile
ind1 = find(error.alpha_v == alpha_v);
ind3 = find(error.lambda_2 == lambda_2);
subplot(1,3,2)
scatter(error.lambda_1(intersect(ind1,ind3)), error.value(intersect(ind1,ind3)))
% Create xlabel
xlabel('\lambda_1');

% Create ylabel
ylabel('Error');

%% plot lambda_1 profile
ind1 = find(error.alpha_v == alpha_v);
ind2 = find(error.lambda_1 == lambda_1);
subplot(1,3,3)
scatter(error.lambda_2(intersect(ind1,ind2)), error.value(intersect(ind1,ind2)))
% Create xlabel
xlabel('\lambda_2');

% Create ylabel
ylabel('Error');

end
