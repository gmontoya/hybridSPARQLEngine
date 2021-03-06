#!/bin/bash

folder=/home/roott/watDivQueries
# initial id
k=$1
# number of vms; step between local ids
x=$2
s=$3
a=$4
# number of clients per vm
n=$5
c=$6
t=$7

cd /home/roott/Client.js-brTPF

#sleep 1s
spids=""
for i in `seq 1 ${n}`; do
    ./evalCorrectness.sh ${s} /home/roott/Client.js-brTPF/config.json ${folder}/client_${k} 5 30 ${t} ${k} ${c} > outputRunCorrectness_${s}_${k} &
    pid=$!
    spids="$spids $pid"
    k=$(($k+$x))
done

for e in $spids; do
    wait $e
done

#date

#ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
