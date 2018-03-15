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

pool = parpool(22) %24 didn't work
rng(sum(100*clock)); % seed used for random selection of voxels (same seed for same experiment)

config = loadjson('config.json')

%calculate parameters to use from taskid
%paramsets={};
%for alpha_v = [0:0.4:7.5]
%    for lambda_1 = [1.0:0.25:2.5]
%        for lambda_2 = [0:0.05:0.2]
%	    params.alpha_v = alpha_v;
%	    params.lambda_1 = lambda_1;
%	    params.lambda_2 = lambda_2;
%	    paramsets = [paramsets, params];
%	end
%    end
%end
%disp(['number of parameter sets', num2str(size(paramsets))])
%params=paramsets{str2num(taskid)}
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
fileName = fullfile(strcat('results_alpha_v_',num2str(alpha_v),'_alpha_f_',num2str(0), '_lambda_1_',num2str(lambda_1),'_lambda_2_',num2str(lambda_2),'.mat'));
save(fileName, 'results')

delete(pool);

