#!/bin/bash

ts="25 50"
ii=0
nvms=4
# number of clients per vm
n=4
# total number of clients in the setup
nc=$((${nvms}*${n}))
resultsFolder=/home/roott/tmp/resultsHybrid_WatDiv_${nc}c
c=false
# maximum number of queries to execute, -1 to execute all of them
m=5
# timeout in minutes
o=5

techniques="hybridTPF"

for t in ${ts}; do
    mkdir ${resultsFolder}_${t}
    ./runWatDivExperiments.sh ${ii} ${nvms} ${techniques} ${t} ${n} ${resultsFolder}_${t} ${c} ${m} ${o} > outputRunWatDivExperiments_hybrid_${nc}c_${t}_
    #./deleteOutputs.sh
done

