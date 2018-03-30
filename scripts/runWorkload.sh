#!/bin/bash

folder=/home/roott/watdiv_queries/watdiv_queries
k=$1
s=$2
a=$3

cd /home/roott/Client.js-brTPF

#sleep 1s

for i in `seq 1 8`; do
    ./eval.sh ${s} /home/roott/Client.js-brTPF/config.json ${folder}_${k} 5 30 30 ${k} > outputEvalWatdiv10M_${s}_${a}_${k} &
    k=$(($k+193))
done

#date

#ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
