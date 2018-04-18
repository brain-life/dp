function [] = fit_model(alpha_v, alpha_f, lambda_1, lambda_2)

if isdeployed
    %command line arguments are passed in as string
    alpha_v = str2num(alpha_v)
    alpha_f = str2num(alpha_f)
    lambda_1 = str2num(lambda_1)
    lambda_2 = str2num(lambda_2)
else
    addpath(genpath('./encode')); %has FitFullModelSampleAlltracts (not the same as brain-life/encode)
    addpath(genpath('/home/hayashis/git/vistasoft'));
    addpath(genpath('/home/hayashis/git/jsonlab'));
end

taskid = getenv('SLURM_ARRAY_TASK_ID')
config = loadjson('config.json')

%need to use different profile directory to make sure multiple jobs won't share the same directory and crash
profile_dir=fullfile('./profile', int2str(feature('getpid')));
mkdir(profile_dir);
c = parcluster();
c.JobStorageLocation = profile_dir;
pool = parpool(c, config.workers);

%rng(sum(100*clock)); % seed used for random selection of voxels (same seed for same experiment)

disp([ 'alpha_v=', num2str(alpha_v), ...
       ' alpha_f=', num2str(alpha_f), ...
       ' lambda_1=', num2str(lambda_1), ...
       ' lambda_2=', num2str(lambda_2)])

%run the model fitting
[~, results] = FitFullModelSampleAllTracts(...
	config.dwi, ...
	config.track, ...
	'bogus', ...
	config.L, ...
	config.p, ...
	config.n, ...
	alpha_v, ...
	alpha_f, ...
	lambda_1, ...
	lambda_2, ...
	config.afq);

%save results
fileName = fullfile(strcat('results_alpha_v_',num2str(alpha_v),'_alpha_f_',num2str(0), '_lambda_1_',num2str(lambda_1),'_lambda_2_',num2str(lambda_2),'.mat'));
save(fileName, 'results')

delete(pool);

