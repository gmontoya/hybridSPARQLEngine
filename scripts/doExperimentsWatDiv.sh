#!/bin/bash

ts="25 50 75 100"
nc=4
smc=1

for t in ${ts}; do
    #mkdir /home/roott/tmp/testResultsWatDiv_${nc}_${t}
    ./runWatDivExperiments.sh "hybridTPF" ${t} ${smc} /home/roott/tmp/testResultsWatDiv_${nc}_${t} > outputrunWatDivExperiments_hybrid_${nc}_${t}_1_ 
    #./deleteOutputs.sh
done

