function [] = AppD_Plot_profiles()
%% 
%% Initialize subject info
info = subject_info_init(); 
%% Set the proper path for VISTASOFT 
addpath(genpath(info.repo.vistasoft));
%% Set the proper path for the ENCODE
addpath(genpath(info.repo.encode_local));

%% Gen tract profiles
Gen_tract_profiles_pair(info, 'CST_L', 'SLF_L', 10)

end