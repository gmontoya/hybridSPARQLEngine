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
c=false
resultsFolder=/home/roott/tmp/resultsHybrid_WatDiv_${nc}c_${c}_rp
# maximum number of queries to execute, -1 to execute all of them
m=-1
# timeout in minutes
o=5
#f=/home/roott/Client.js-brTPF/config.json
f=/home/roott/Client.js-brTPF/config-reverseproxy.json

techniques="hybridTPF"

for t in ${ts}; do
    mkdir ${resultsFolder}_${t}
    ./runWatDivExperiments.sh ${ii} ${nvms} ${techniques} ${t} ${n} ${resultsFolder}_${t} ${c} ${m} ${o} ${f} > outputRunWatDivExperiments_hybrid_${nc}c_${t}_${c}
    #./deleteOutputs.sh
done

