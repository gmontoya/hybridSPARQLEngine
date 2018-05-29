#!/bin/bash

techniques=$1
#techniques="brTPF endpoint"
#techniques="endpoint"
#declare -a addresses=("172.19.2.115" "172.19.2.107" "172.19.2.118" "172.19.2.111")
#declare -a addresses=("172.19.2.107")
threshold=$2

resultsFolder=$4
#resultsFolder=/home/roott/tmp/resultsWatDiv

# maximum number of vms, step between clients in the same vm
mn=4

# initial id
b=1
# number of clients per vm
n=$3
#4
# number of vms
x=${#addresses[@]}
y=$(($x-1))
# number of clients in the setup
s=$(($x*$n))
u=$(($s-1))
# save the initial id for processing the output
k=${b}
# count bytes? (true or false)
c=$5
# label for the results of this experiment
e=${s}c_${c}

for t in ${techniques}; do
  spids=""
  #b=0
  for i in `seq 0 ${y}`; do
    a=${addresses[$i]}
    echo "running ${t} experiments on ${a}"
    ssh roott@${a} 'bash -s' < runWorkloadWatDiv.sh ${b} ${mn} ${t}-client-eval ${a} ${n} ${c} ${threshold} ${t}  > outputRunWorkloadWatDiv_${t}_${a}_${b}_${c} &
    pid=$!
    spids="$spids $pid"
    b=$(($b+1))
  done

  for i in $spids; do
    wait $i
  done
done

for t in ${techniques}; do
  rm ${resultsFolder}/res_${t}_${e}.csv
  for j in `seq 0 ${y}`; do
    l=$k
    a=${addresses[$j]} 
    for i in `seq 1 $n`; do

      scp roott@${a}:/home/roott/Client.js-brTPF/eval_${t}_${l}.csv ${resultsFolder}/
      cat ${resultsFolder}/eval_${t}_${l}.csv >> ${resultsFolder}/res_${t}_${e}.csv
      l=$(($l+${mn})) 
    done
    k=$(($k+1))
  done
  ./processOutput.sh ${resultsFolder}/res_${t}_${e}.csv
done
