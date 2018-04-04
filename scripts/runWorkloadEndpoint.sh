#!/bin/bash

folder=/home/roott/watdiv_queries/watdiv_queries
k=$1
a=$2

cd /home/roott/Client.js-brTPF/scripts

#sleep 1s

for i in `seq 1 8`; do
    ./evalUsingEndpoint.sh ${folder}_${k} http://172.19.2.112:8890/sparql 5 > outputEvalEndpointWatdiv10M_${a}_${k} &
    k=$(($k+193))
done

#date

#ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
