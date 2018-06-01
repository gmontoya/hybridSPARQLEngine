#!/bin/bash


techniques="brTPF-client-eval hybridTPF-client-eval endpoint-client-eval"
addresses="172.19.2.115 172.19.2.107 172.19.2.118 172.19.2.111"
# initial id, it should be 0 for WatDiv setup
b=0
# number of clients to consider per vm
n=8
# count bytes? (true or false); use false to measure the execution time and true to measure data transfer
c=false

for t in ${techniques}; do
  spids=""
  for a in ${addresses}; do    
    ssh roott@${a} 'bash -s' < runWorkload.sh ${b} ${t} ${a} ${n} ${c} > outputRunWorkload_${t}_${a}_${b}_${c} &
    pid=$!
    spids="$spids $pid"
    b=$(($b+1544))
  done

  for e in $spids; do
    wait $e
  done
done
