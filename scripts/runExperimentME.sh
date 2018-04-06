#!/bin/bash

#s=$1
techniques="brTPF-client-eval hybridTPF-client-eval endpoint-client-eval"
addresses="172.19.2.115 172.19.2.107 172.19.2.118 172.19.2.111"
b=13
# initial id
n=4
# number of clients per vm
c=true
# count bytes? (true or false)

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

