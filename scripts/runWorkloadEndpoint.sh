#!/bin/bash

folder=/home/roott/Client.js-brTPF/queries/more
k=$1
a=$2
n=$3

cd /home/roott/Client.js-brTPF/scripts

#sleep 1s

spids=""
for i in `seq 1 ${n}`; do
    ./evalUsingEndpoint.sh ${folder} http://172.19.2.100:8893/sparql 5 > outputEvalEndpointDBpedia_${a}_${k}_${n}c &
    pid=$!
    spids="$spids $pid"
    k=$(($k+1))
done

for e in $spids; do
    wait $e
done

#date

#ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
