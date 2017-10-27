function [] = Prepare_batch_data_HCP3T_105115(nBatch)


%% Set the Path for the output
dataOutputPath = '/N/dc2/projects/lifebid/code/ccaiafa/Development/Dictionary_learning/Diffusion_predictor/Unique_kernel/Experiments/Grid_Search_in_the_cloud/Diffusion_predictor_brain-life/';

%% Set the proper path for VISTASOFT 
vista_soft_path = '/N/dc2/projects/lifebid/code/vistasoft/';
addpath(genpath(vista_soft_path));

%% Set the proper path for the ENCODE
ENCODE_path = '/N/dc2/projects/lifebid/code/ccaiafa/Development/Dictionary_learning/Unique_kernel/encode/';
addpath(genpath(ENCODE_path));

%% HCP dataset 
dataRootPath = '/N/dc2/projects/lifebid/2t1/HCP/';
subject = '105115';
conn = 'NUM01'; % 
param = 'lmax10'; % {'lmax10','lmax12','lmax2','lmax4','lmax6','lmax8', ''}
alg = 'SD_PROB'; % {'SD_PROB', 'SD_STREAM','tensor'}

% Generate fe_strucure
%% Build the file names for the diffusion data, the anatomical MRI.
dwiFile       = deblank(ls(fullfile(dataRootPath,subject,'diffusion_data','*b2000_aligned*.nii.gz')));

fgFileName    = deblank(ls(fullfile(dataRootPath,subject,'fibers_new', strcat('*b2000*',char(param),'*',char(alg),'*',conn,'*','500000.tck'))));
feFileName    = strcat(subject,'_',alg,'_',param,'_',conn);  

%% Initialize the model

L = 45;
p=0.5;

tic
fe = feConnectomeInit(dwiFile,fgFileName,feFileName,[] ,[], [], L, [0,1],0); % We set dwiFileRepeat =  run 02
disp(' ')
disp(['Time for model construction ','(L=',num2str(L),')=',num2str(toc),'secs']);

%% Define training-validation directions by random
nTheta = feGet(fe,'nbvals');
[nVoxels] = feGet(fe,'nvoxels');
bvecs        = feGet(fe,'bvecs');                      % bvecs
bvals        = feGet(fe,'bvals');                      % bvals

%nVoxels = 1000; % For testing purposes ONLY

ind_dirs = randperm(nTheta); 

nTrain = round(p*nTheta); % Number of training directions
nVal = nTheta - nTrain; % Number of validation directions

ind_train = ind_dirs(1:nTrain); % Set of training directions
ind_val = ind_dirs(nTrain+1:end); % Set of validation directions

Batch_size = round(nVoxels/nBatch);

for n=1:nBatch
    
    n0 = (nBatch - 1)*Batch_size + 1;
    nf = min(nBatch*Batch_size + 1, nVoxels);
    
    %% Fit model to TRAINING DATA
    Y = fe.life.diffusion_signal_img(n0:nf,ind_train)';
    Phi = fe.life.M.Phi(:,n0:nf,:);
    
    disp(['SAVING BATCH DATA',num2str(n)]);
    save(fullfile(dataOutputPath,strcat('input_data_',num2str(n),'.mat')), ...
        'Y', 'Phi','ind_train','ind_val','bvecs','bvals','-v7.3')
end

% Prepare submission file, one per batch

process =1;
for n=1:nBatch
    name = strcat('osg_',subject,'_batch_',num2str(n));
    FileName    = fullfile(dataOutputPath, strcat(name,'.submit'));
    fid = fopen(FileName, 'wt' );
    fprintf(fid, 'Universe = vanilla \n\n');
    fprintf(fid, '+ProjectName="Diffusion-predictor" \n\n');
    fprintf(fid, 'Executable = run_osg.sh \n');
    fprintf(fid, strcat('transfer_input_files = bin/Process_batch_data,input_data_',num2str(n),'.mat \n'));
    fprintf(fid, 'should_transfer_files = YES \n\n');
    
    fprintf(fid, strcat('Output = log/',num2str(n),'.$(Process).out \n'));
    fprintf(fid, strcat('Error = log/',num2str(n),'.$(Process).err \n'));    
    fprintf(fid, strcat('Log = log/',num2str(n),'.$(Process).log \n\n'));  
    
    fprintf(fid, 'requirements = OSGVO_OS_STRING == "RHEL 6" && Arch == "X86_64" && HAS_MODULES == True \n\n');    
    
    for alpha_v = 0:0.1:8
        for lambda_1 = 0.2:0.05:2
            for r = 0:0.05:0.7
                fprintf(fid, 'Arguments = %s %s %s %s \n',num2str(n),num2str(alpha_v),num2str(lambda_1),num2str(r));
                fprintf(fid, 'queue \n\n');
                process = process + 1;
            end
        end
    end
    
    fclose(fid);
    
end
disp(['Total number of processes = ',num2str(process)])

rmpath(genpath(vista_soft_path));
rmpath(genpath(ENCODE_path));

end
