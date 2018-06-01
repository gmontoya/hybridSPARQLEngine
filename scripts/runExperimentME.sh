#!/bin/bash

#s=$1
techniques="endpoint-client-eval"
#techniques="brTPF-client-eval hybridTPF-client-eval endpoint-client-eval"
addresses="172.19.2.115 172.19.2.107 172.19.2.118 172.19.2.111"
# initial id
# use values that do not overlap with the ones of the WatDivExperiment (avoid 0, 193, 386, 579,...,5983)
b=13
# number of clients per vm
n=4
# count bytes? (true or false); use false to measure the execution time and true to measure data transfer
c=true

for t in ${techniques}; do
  spids=""
  for a in ${addresses}; do    
    ssh roott@${a} 'bash -s' < runWorkloadME.sh ${b} ${t} ${a} ${n} ${c}  > outputRunWorkloadME_${t}_${a}_${b}_${c} &
    pid=$!
    spids="$spids $pid"
    b=$(($b+$n))
  done

  for e in $spids; do
    wait $e
  done
done

