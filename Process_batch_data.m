function [] = Process_batch_data(i,alpha_v, lambda_1, r)

i = str2num(i)
alpha_v = str2num(alpha_v)
lambda_1 = str2num(lambda_1)
r = str2num(r)

input_filename = strcat('input_data_',num2str(i),'.mat');

sprintf('i = %d', i)
sprintf('alpha_v = %f', alpha_v)
sprintf('lambda_1 = %f', lambda_1)
sprintf('r = %f', r)
sprintf('input %s', input_filename)

%% Set the proper path for the ENCODE
switch getenv('ENV')
case 'IUHPC'
	disp('loading encode')
	addpath(genpath('/N/dc2/projects/lifebid/code/ccaiafa/Development/Dictionary_learning/Unique_kernel/encode/'));
	addpath(genpath('/N/dc2/projects/lifebid/code/vistasoft/'))
end

load(deblank(ls(input_filename)));

[nTrain,nVoxels] = size(Y);
[nAtoms] = size(Phi,1);
[nFibers] = size(Phi,3);


% Build dictionary with tensor parameters lambda_1, lambda_2

L = 45;

lambda_2 = lambda_1*r;

% Build dictionary matrix
D = BuildDictionaries(L,L,bvecs,bvals,lambda_1,lambda_2);
D = D(ind_train,:); % use training directions only

% Fit B and s0 to measurements (alternate between B and s0)
Niter = 50;
threshold = 1e-8;

Erro_vs_iter = zeros(1,Niter);

B = ttv(Phi,ones(nFibers,1),3);
[ind, val] = find(B);
B = sparse(ind(:,1),ind(:,2),val,nAtoms,nVoxels);
normY = norm(Y,'fro');
s0 = zeros(nVoxels,1);

Error = norm(Y - ones(nTrain,1)*s0' - D*B,'fro')/normY;

delta = Inf;
n = 1;
disp(' ')
while (n<= Niter)&&(delta > threshold)
    disp(['IN LOOP iter ',num2str(n),' Error=', num2str(Error), ' nnz(B)=',num2str(nnz(B)/numel(B)),' delta=',num2str(delta) ])
    %fprintf('.');
    
    % Min over B
    B = Min_over_B(Y - ones(nTrain,1)*s0',B,D,alpha_v);
    
    % Min over s0
    s0 = Min_over_s0(Y - D*B);
    
    Error_vs_iter(n) = Error;
    Error_ant = Error;
    Error = norm(Y - ones(nTrain,1)*s0' - D*B,'fro')/normY;
    delta = abs(Error - Error_ant);
    n = n + 1;
end

disp(['SAVING PROCESSED DATA',num2str(i)]);
save(strcat('output_data_',num2str(i),'_alpha_v_',num2str(alpha_v),'_lambda_1_',num2str(lambda_1),'_lambda_2_',num2str(lambda_2),'.mat'), ...
    'B', 's0', 'Phi','Error_vs_iter','-v7.3')

%rmpath(genpath(vista_soft_path));
%rmpath(genpath(ENCODE_path));

end
 
function [B] = Min_over_B(Y,B,D,lambda)
nVoxels = size(Y,2);
parfor v=1:nVoxels
    [ind, val] = find(B(:,v));
    
    C = [D(:,ind); lambda*eye(length(ind))]; % augmented matrix for Tikhonov regularizer
    d = [Y(:,v); zeros(length(ind),1)];
    %b = lsqnonneg(C,d);
    opt = solopt;
    out = bbnnls_orig(C, d, zeros(size(C,2),1), opt);
    b = out.x;
    %b(b==0) = eps;
    %B(ind,v) = b;
    Bvals{v}.ind = ind;
    Bvals{v}.val = b;
    %disp(['voxel ',num2str(v)]);
end
for v=1:nVoxels
    B(Bvals{v}.ind,v) = Bvals{v}.val;
end

end


function [s0] = Min_over_s0(E)
s0 = (sum(E,1)/size(E,1))';

s0(s0<=0) = 0;

end

function options = solopt(varargin)
% SOLOPT  --  Creates a default options structure for BBNNLS
%
% OPTIONS = SOLOPT
%

options.asgui = 0;
options.beta = 0.0498;
options.compute_obj = 1;
% diminishing scalar; beta^0 =  opt.dimbeg
% beta^k = opt.dimbeg / k^opt.dimexp
options.dimexp = .5;
options.dimbeg = 5;
options.maxit = 1000;
options.maxtime = 10;
options.maxnull = 10;
options.max_func_evals = 30;
options.pbb_gradient_norm = 1e-9;
options.sigma = 0.298;
options.step  = 1e-4;
options.tau = 1e-7;             
options.time_limit = 0;
options.tolg = 1e-3;
options.tolx = 1e-8;
options.tolo = 1e-5;
options.truex=0;
options.xt=[];
options.use_kkt = 0;
options.use_tolg = 1;
options.use_tolo = 0;
options.use_tolx = 0;
options.useTwo = 0;
options.verbose = 0;                    % initially
if nargin == 1
  options.variant = varargin{1};
else   % Default
  options.variant = 'SBB';
end
end
