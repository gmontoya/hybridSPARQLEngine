#!/bin/bash

#techniques=$1
#techniques="endpoint"
techniques="brTPF hybridTPF endpoint"
declare -a addresses=("172.19.2.115" "172.19.2.107" "172.19.2.118" "172.19.2.111")
#declare -a addresses=("172.19.2.115")
#threshold=$2

#resultsFolder=$4
resultsFolder=/home/roott/tmp/resultsWatDiv/correctness

# initial id
b=0
# number of clients per vm
n=1
#4
# number of vms
x=${#addresses[@]}
y=$(($x-1))
# number of clients in the setup
s=$(($x*$n))
u=$(($s-1))
# label for the results of this experiment
e=${s}c_${c}
# save the initial id for processing the output
k=${b}
# count bytes? (true or false)
c=true
# label for the results of this experiment
e=${s}c_${c}
# save the initial id for processing the output
k=${b}

for t in ${techniques}; do
  spids=""
  b=0
  for i in `seq 0 ${y}`; do
    a=${addresses[$i]}
    echo "running ${t} experiments on ${a}"
    ssh roott@${a} 'bash -s' < runWorkloadWatDivCorrectness.sh ${b} 4 ${t}-client-eval ${a} ${n} ${c} ${threshold}  > outputRunWorkloadWatDiv_${t}_${a}_${b}_${c} &
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
  for l in `seq 0 ${u}`; do
    i=$(($l % 4))
    a=${addresses[$i]}

    scp roott@${a}:/home/roott/Client.js-brTPF/outputCorrectness_${l} ${resultsFolder}/
    #cat ${resultsFolder}/eval_${t}_${l}.csv >> ${resultsFolder}/res_${t}_${e}.csv
  done
  #./processOutput.sh ${resultsFolder}/res_${t}_${e}.csv
done
