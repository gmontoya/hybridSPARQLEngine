#!/bin/bash

#s=$1
techniques="brTPF hybridTPF endpoint"
addresses="172.19.2.115 172.19.2.107 172.19.2.118 172.19.2.111"
resultsFolder=/home/roott/tmp/resultsTmp

# initial id
b=13
# number of clients per vm
n=4
# number of vms
x=`wc -w <<< ${addresses}`
# number of clients in the setup
s=$(($x*$n))
# count bytes? (true or false)
c=true
# label for the results of this experiment
e=${s}c_${c}
# save the initial id for processing the output
k=${b}

for t in ${techniques}; do
  spids=""
  for a in ${addresses}; do
    ssh roott@${a} 'bash -s' < runWorkloadME.sh ${b} ${t}-client-eval ${a} ${n} ${c}  > outputRunWorkloadME_${t}_${a}_${b}_${c} &
    pid=$!
    spids="$spids $pid"
    b=$(($b+$n))
  done

  for e in $spids; do
    wait $e
  done
done

for t in ${techniques}; do
  rm res_${t}_${e}.csv
  for a in ${addresses}; do
    for i in `seq 1 ${n}`; do
      scp roott@${a}:/home/roott/Client.js-brTPF/eval_${t}_${k}.csv ${resultsFolder}/
      cat ${resultsFolder}/eval_${t}_${k}.csv >> ${resultsFolder}/res_${t}_${e}.csv
      k=$(($k+1))
    done
  done
  ./processOutput.sh ${resultsFolder}/res_${t}_${e}.csv
done
