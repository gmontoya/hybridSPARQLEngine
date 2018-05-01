#!/bin/bash

#s=$1
techniques="brTPF endpoint"
declare -a addresses=("172.19.2.115" "172.19.2.107" "172.19.2.118" "172.19.2.111")

resultsFolder=/home/roott/tmp/resultsTmp

# initial id
b=0
# number of clients per vm
n=4
# number of vms
x=`wc -w <<< ${addresses}`
y=$(($x-1))
# number of clients in the setup
s=$(($x*$n))
u=$(($s-1))
# count bytes? (true or false)
c=false
# label for the results of this experiment
e=${s}c_${c}
# save the initial id for processing the output
k=${b}

for t in ${techniques}; do
  spids=""
  b=0
  for i in `seq 0 ${y}`; do
    a=${addresses[$i]}
    ssh roott@${a} 'bash -s' < runWorkloadDBpedia2.sh ${b} ${x} ${t}-client-eval ${a} ${n} ${c}  > outputRunWorkloadDBpedia2_${t}_${a}_${b}_${c} &
    pid=$!
    spids="$spids $pid"
    b=$(($b+1))
  done

  for e in $spids; do
    wait $e
  done
done

for t in ${techniques}; do
  rm ${resultsFolder}/res_${t}_${e}.csv
  for l in `0 ${u}`; do
    i=$(($l % 4))
    a=${addresses[$i]}

    scp roott@${a}:/home/roott/Client.js-brTPF/eval_${t}_${l}.csv ${resultsFolder}/
    cat ${resultsFolder}/eval_${t}_${l}.csv >> ${resultsFolder}/res_${t}_${e}.csv
  done
  ./processOutput.sh ${resultsFolder}/res_${t}_${e}.csv
done
