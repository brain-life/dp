#!/bin/bash

log=compiled/commit_ids.txt
true > $log
echo "/home/hayashis/git/encode-dp" >> $log
(cd /home/hayashis/git/encode && git log -1) >> $log
echo "/home/hayashis/git/vistasoft" >> $log
(cd /home/hayashis/git/vistasoft && git log -1) >> $log
echo "/home/hayashis/git/mba " >> $log
(cd /home/hayashis/git/mba && git log -1) >> $log
echo "/home/hayashis/git/jsonlab" >> $log
(cd /home/hayashis/git/jsonlab && git log -1) >> $log

cat > build.m <<END
addpath(genpath('/home/hayashis/git/encode-dp'));
addpath(genpath('/home/hayashis/git/vistasoft'));
addpath(genpath('/home/hayashis/git/mba'))
addpath(genpath('/home/hayashis/git/jsonlab'));

mcc -m -R -nodisplay -a /home/hayashis/git/vistasoft/mrAnatomy/Segment -d compiled fit_model
mcc -m -R -nodisplay -a /home/hayashis/git/vistasoft/mrAnatomy/Segment -d compiled find_best
mcc -m -R -nodisplay -a /home/hayashis/git/vistasoft/mrAnatomy/Segment -d compiled compute_profiles
mcc -m -R -nodisplay -a /home/hayashis/git/vistasoft/mrAnatomy/Segment -d compiled remove_tracts_from_prediction
exit
END
matlab -nodisplay -nosplash -r build && rm build.m

