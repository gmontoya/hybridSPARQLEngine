#!/bin/bash

addresses="172.19.2.115 172.19.2.107 172.19.2.118 172.19.2.111"
b=3
n=8
c=32
spids=""

for a in ${addresses}; do    
    ssh roott@${a} 'bash -s' < runWorkloadEndpoint.sh ${b} ${a} ${n} > outputRunWorkloadEndpoint_${a}_${b}_${n}c &
    pid=$!
    spids="$spids $pid"
    b=$(($b+$n))
done

for e in $spids; do
    wait $e
done

k=3
rm /home/roott/tmp/resultsTmp/*
#rm /home/roott/tmp/results/res_python_endpoint_${c}c.csv

for a in ${addresses}; do
  for i in `seq 1 ${n}`; do
    scp roott@${a}:/home/roott/Client.js-brTPF/scripts/outputEvalEndpointDBpedia_${a}_${k}_${n}c /home/roott/tmp/resultsTmp/
    cat /home/roott/tmp/resultsTmp/outputEvalEndpointDBpedia_${a}_${k}_${n}c >> /home/roott/tmp/results/res_python_endpoint_${c}c.csv
    k=$(($k+1))
  done
done
