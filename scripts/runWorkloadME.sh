#!/bin/bash

folder=/home/roott/Client.js-brTPF/queries/more
k=$1
s=$2
a=$3
n=$4
c=$5
m=-1
e=""

cd /home/roott/Client.js-brTPF

#sleep 1s
spids=""
for i in `seq 1 ${n}`; do
    ./eval.sh ${s} /home/roott/Client.js-brTPF/configDBpedia201604.json ${folder} 5 30 30 ${k} ${c} "${e}" ${m} > outputEvalDBpedia_${s}_${a}_${k}_${c} &
    pid=$!
    spids="$spids $pid"
    k=$(($k+1))
done

for e in $spids; do
    wait $e
done

#date

#ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
