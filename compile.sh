#!/bin/bash
cat > build.m <<END
addpath(genpath('./encode')); 
addpath(genpath('/home/hayashis/git/vistasoft'));
addpath(genpath('/home/hayashis/git/jsonlab'));
mcc -m -R -nodisplay -d compiled fit_model
mcc -m -R -nodisplay -d compiled find_best
exit
END
matlab -nodisplay -nosplash -r build && rm build.m

