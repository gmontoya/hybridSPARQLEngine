#!/bin/bash

folder=/home/roott/watDivQueries
# initial id
k=$1
# number of vms; step between local ids
x=$2
# technique
h=${3}
s=${h}-client-eval
a=$4
# number of clients per vm
n=$5
c=$6
t=$7
e="http://172.19.2.112:8890/sparql?default-graph-uri=http%3A%2F%2Fwatdiv10M&query="
m=$8
o=$9
f=${10}

cd /home/roott/Client.js-brTPF

#sleep 1s
spids=""
for i in `seq 1 ${n}`; do
    rm /home/roott/Client.js-brTPF/eval_${h}_${k}.csv
    ./eval.sh ${s} ${f} ${folder}/client_${k} ${o} 30 ${t} ${k} ${c} ${e} ${m} > outputEvalWatDiv_${s}_${a}_${k}_${c} &
    pid=$!
    spids="$spids $pid"
    k=$(($k+$x))
done

for e in $spids; do
    wait $e
done

#date

#ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
