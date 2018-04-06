#!/bin/bash

sed -i".bkp" 's/b=[0-9A-Za-z ]*$/b=27/' runExperimentME.sh
sed -i".bkp" 's/n=[0-9A-Za-z ]*$/n=4/' runExperimentME.sh
sed -i".bkp" 's/c=[0-9A-Za-z ]*$/c=false/' runExperimentME.sh
./runExperimentME.sh > outputRunExperimentME_27_4_false
sed -i".bkp" 's/b=[0-9A-Za-z ]*$/b=75/' runExperimentME.sh
sed -i".bkp" 's/c=[0-9A-Za-z ]*$/c=true/' runExperimentME.sh
./runExperimentME.sh > outputRunExperimentME_75_4_true
./runExperimentME_.sh > outputRunExperimentME_123_1_false
sed -i".bkp" 's/b=[0-9A-Za-z ]*$/b=124/' runExperimentME_.sh
sed -i".bkp" 's/c=[0-9A-Za-z ]*$/c=true/' runExperimentME_.sh
./runExperimentME_.sh > outputRunExperimentME_124_1_true
