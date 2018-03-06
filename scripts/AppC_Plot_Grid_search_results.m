function [] = AppC_Plot_Grid_search_results()
%% 
%% Initialize subject info
info = subject_info_init(); 

% Find optimal values of parameters and plot optimization surface
[~, ~, ~, ~] = Get_surface_grid_search(info.output.results_root);

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