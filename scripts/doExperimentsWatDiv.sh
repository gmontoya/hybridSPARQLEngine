#!/bin/bash

ts="25 50 75"
# initial vm index
ii=0
# number of vms
nvms=4
# number of clients per vm
n=4
# total number of clients in the setup
nc=$((${nvms}*${n}))
c=true
resultsFolder=/home/roott/tmp/resultsHybrid_WatDiv_${nc}c_${c}
# maximum number of queries to execute, -1 to execute all of them
m=-1
# timeout in minutes
o=5

techniques="hybridTPF"

for t in ${ts}; do
    mkdir ${resultsFolder}_${t}
    ./runWatDivExperiments.sh ${ii} ${nvms} ${techniques} ${t} ${n} ${resultsFolder}_${t} ${c} ${m} ${o} > outputRunWatDivExperiments_hybrid_${nc}c_${t}_${c}
    #./deleteOutputs.sh
done

