function [] = find_best()

if ~isdeployed

    %for matlab2
    addpath(genpath('/home/hayashis/git/encode-dp'));
    addpath(genpath('/home/hayashis/git/vistasoft'));
    addpath(genpath('/home/hayashis/git/jsonlab'));

    %for hpc
    addpath(genpath('/N/u/brlife/git/encode-dp'));
    addpath(genpath('/N/u/brlife/git/vistasoft'));
    addpath(genpath('/N/u/brlife/git/jsonlab'));
end

% load my own config.json
config = loadjson('config.json')

disp('loading dt6.mat')
dt6 = loadjson(fullfile(config.dtiinit, 'dt6.json'))
aligned_dwi = fullfile(config.dtiinit, dt6.files.alignedDwRaw)

%need to use different profile directory to make sure multiple jobs won't share the same directory and crash
profile_dir=fullfile('./profile', int2str(feature('getpid')));
mkdir(profile_dir);
c = parcluster();
c.JobStorageLocation = profile_dir;
pool = parpool(c, config.workers);

%load optimal values of parameters
alpha_f = 0;
[alpha_v, lambda_1, lambda_2, ~] = Get_surface_grid_search('results');

% Fit Full Model using optimal parameters and 100% of gradient directions
tic
disp(['FitFullModel.. (alpha_v, lambda_, lambda_2)=(',num2str(alpha_v),',',num2str(lambda_1),',',num2str(lambda_2),')'])
[fe, results] = FitFullModel(...
    aligned_dwi, ...
    config.track, ...
    'bogus', ...
    config.L, ...
    1, ...
    alpha_v, ...
    alpha_f, ...
    lambda_1, ...
    lambda_2);

TimeFullFit = toc/60; % Time in minutes
disp(['Time Fitting Full Model=',num2str(TimeFullFit),'mins'])

%fe will be >2G need to save in matlab format
save('fe_optimal.mat', 'fe', '-v7.3');

info.parameters.opt.alpha_v = alpha_v;
info.parameters.opt.lambda_1 = lambda_1;
info.parameters.opt.lambda_2 = lambda_2;
info.fit = results;
save('info.mat', 'info');

%rmpath(info.repo.encode_local);
%rmpath(info.repo.vistasoft);

delete(pool);

end

%% Function that read all 
function [alpha_v_min, lambda_1_min, lambda_2_min, error] = Get_surface_grid_search(dataInputPath)
listing = dir(strcat(dataInputPath,'/alpha*.mat'));
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
%set(gcf,'units','points','position',[200,400,800,200])
%hold on
ind2 = find(error.lambda_1 == lambda_1);
ind3 = find(error.lambda_2 == lambda_2);
xs = error.alpha_v(intersect(ind2,ind3));
ys = error.value(intersect(ind2,ind3));

%subplot(1,3,1)
scatter(xs, ys)
xlabel('\alpha_v');
ylabel('Error');
saveas(gcf, 'alpha_v.profile.png');
close all;

plot1 = make_plotly_data(xs, ys, 'alpha_v profile', 'alpha_v', 'Error');

%% plot lambda_1 profile
figure
%set(gcf,'units','points','position',[200,400,800,200])
%hold on
ind1 = find(error.alpha_v == alpha_v);
ind3 = find(error.lambda_2 == lambda_2);
xs = error.lambda_1(intersect(ind1,ind3));
ys = error.value(intersect(ind1,ind3));

%subplot(1,3,2)
scatter(xs, ys)
xlabel('\lambda_1');
ylabel('Error');
saveas(gcf, 'lambda_1.profile.png');
close all;

plot2 = make_plotly_data(xs, ys, 'lambda_1 profile', 'lambda_1', 'Error');

%% plot lambda_1 profile
figure
%set(gcf,'units','points','position',[200,400,800,200])
ind1 = find(error.alpha_v == alpha_v);
ind2 = find(error.lambda_1 == lambda_1);
xs = error.lambda_2(intersect(ind1,ind2));
ys = error.value(intersect(ind1,ind2));

%subplot(1,3,3)
scatter(xs, ys)
xlabel('\lambda_2');
ylabel('Error');
saveas(gcf, 'lambda_2.profile.png');
close all;

plot3 = make_plotly_data(xs, ys, 'lambda_2 profile', 'lambda_2', 'Error');

product_json = {plot1, plot2, plot3};
savejson('brainlife', product_json, 'product.json');

end

%% make plotly plot data
function out = make_plotly_data(xs, ys, plotTitle, xaxisTitle, yaxisTitle)

out = struct;

out.data = struct;
out.layout = struct;
out.type = 'plotly';
out.name = plotTitle;

out.data.x = xs;
out.data.y = ys;
out.data.type = 'scatter';
out.data.mode = 'markers';
out.data.marker = struct;
out.data.marker.symbol = 'circle-open';
out.data.marker.size = 8;
out.data = {out.data};

%out.layout.title = plotTitle;

out.layout.xaxis = struct;
out.layout.xaxis.title = xaxisTitle;
out.layout.xaxis.type = 'linear';

out.layout.yaxis = struct;
out.layout.yaxis.title = yaxisTitle;
out.layout.yaxis.type = 'linear';

end
