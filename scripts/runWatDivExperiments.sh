#!/bin/bash

# initial vm id
ii=$1
# number of vms
nvms=$2
# initial client id
k=${ii}
techniques=$3
threshold=$4
# number of clients per vm
n=$5
resultsFolder=$6
# count bytes? (true or false)
c=$7
# maximum number of queries to execute, -1 to execute all of them
m=$8
# timeout in minutes
o=$9
f=${10}

#techniques="brTPF endpoint"
#techniques="endpoint"
declare -a all=("172.19.2.115" "172.19.2.107" "172.19.2.118" "172.19.2.111")
addresses=("${all[@]:${ii}:${nvms}}")

# maximum number of vms, step between clients in the same vm
mn=${#all[@]}

# number of vms
x=${#addresses[@]}
y=$(($x-1))
# number of clients in the setup
s=$(($x*$n))
u=$(($s-1))
# label for the results of this experiment
e=${s}c_${c}

for t in ${techniques}; do
  spids=""
  b=$k
  for i in `seq 0 ${y}`; do
    a=${addresses[$i]}
    echo "running ${t} experiments on ${a}"
    ssh roott@${a} 'bash -s' < runWorkloadWatDiv.sh ${b} ${mn} ${t} ${a} ${n} ${c} ${threshold} ${m} ${o} ${f} > outputRunWorkloadWatDiv_${t}_${a}_${b}_${c} &
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
