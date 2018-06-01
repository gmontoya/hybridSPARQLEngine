#!/bin/bash

#addresses="172.19.2.115"
addresses="172.19.2.115 172.19.2.107 172.19.2.118 172.19.2.111"
#addresses="172.19.2.107"
# initial id, it should be 0 for WatDiv setup
b=0
# number of clients to consider per vm
n=8
# count bytes? (true or false); use false to measure the execution time and true to measure data transfer
c=32
spids=""

k=0
for a in ${addresses}; do
    ssh roott@${a} 'bash -s' < runWorkloadEndpoint.sh ${b} ${a} ${n} ${k} > outputRunWorkloadEndpoint_${a}_${b}_${n}c &
    pid=$!
    spids="$spids $pid"
    b=$(($b+$n))
    k=$(($k+(8*193)))
done

for e in $spids; do
    wait $e
done

k=0
rm /home/roott/tmp/resultsTmp/*
#rm /home/roott/tmp/results/res_python_endpoint_${c}c.csv

for a in ${addresses}; do
  for i in `seq 1 ${n}`; do
    scp roott@${a}:/home/roott/Client.js-brTPF/scripts/outputEvalEndpointWatDiv_${a}_${k}_${n}c /home/roott/tmp/resultsTmp/
    cat /home/roott/tmp/resultsTmp/outputEvalEndpointWatDiv_${a}_${k}_${n}c >> /home/roott/tmp/results/res_python_endpoint_${c}c.csv
    k=$(($k+1))
  done
done
