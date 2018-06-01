#!/bin/bash

##folder=/home/roott/watdiv_queries/results
folder=/home/roott/watDivQueries
# initial id
k=$1
# number of vms; step between local ids
#x=$2
s=$2
#a=$4
# number of clients per vm
n=$3
c=$4
max=15
t=5
##cd /home/roott/brTPF/Client.js-brTPF
cd /home/roott/Client.js-brTPF
#sleep 1s
spids=""
for i in `seq 1 ${n}`; do
    echo "./eval.sh ${s} /home/roott/Client.js-brTPF/config.json ${folder}/client_${k} ${t} 30 30 ${k} ${c} "http://172.19.2.112:8890/sparql?default-graph-uri=http%3A%2F%2Fwatdiv10M&query=" ${max} > outputEvalWatDivTest_${s}_${k}_${c} &"
    ./eval.sh ${s} /home/roott/Client.js-brTPF/config.json ${folder}/client_${k} ${t} 30 30 ${k} ${c} "http://172.19.2.112:8890/sparql?default-graph-uri=http%3A%2F%2Fwatdiv10M&query=" ${max} > outputEvalWatDivTest_${s}_${k}_${c} &
    pid=$!
    spids="$spids $pid"
    k=$(($k+4))
done

for e in $spids; do
    wait $e
done

#date

#ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
