#!/bin/bash
cat > build.m <<END
%addpath(genpath('/home/hayashis/git/encode'));

addpath(genpath('./encode'));
addpath(genpath('/home/hayashis/git/vistasoft'));
addpath(genpath('/home/hayashis/git/jsonlab'));
%mcc -m -R -nodisplay -d compiled fit_model
%mcc -m -R -nodisplay -d compiled find_best
mcc -m -R -nodisplay -d compiled compute_profiles
exit
END
matlab -nodisplay -nosplash -r build && rm build.m

