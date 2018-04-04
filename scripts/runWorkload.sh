#!/bin/bash

folder=/home/roott/watdiv_queries/watdiv_queries
k=$1
s=$2
a=$3
n=$4

cd /home/roott/Client.js-brTPF

#sleep 1s
spids=""

for i in `seq 1 ${n}`; do
    ./eval.sh ${s} /home/roott/Client.js-brTPF/config.json ${folder}_${k} 5 30 30 ${k} > outputEvalWatdiv10M_${s}_${a}_${k} &
    pid=$!
    spids="$spids $pid"
    k=$(($k+193))
done

for e in $spids; do
    wait $e
done
#date

#ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
