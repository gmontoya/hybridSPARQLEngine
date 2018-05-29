#!/bin/bash

#s=$1
techniques="hybridTPF"
#"brTPF hybridTPF endpoint"
#declare -a addresses=("172.19.2.118" "172.19.2.111")
#declare -a addresses=("172.19.2.118")

resultsFolder=/home/roott/tmp/resultsTestWatDiv

# initial id
b=0
# number of clients
n=2
#4
# number of vms
#x=${#addresses[@]}
#y=$(($x-1))
# number of clients in the setup
#s=$(($x*$n))
u=$(($n-1))
# count bytes? (true or false)
c=false
# label for the results of this experiment
e=${n}c_${c}
# save the initial id for processing the output
k=${b}

for t in ${techniques}; do
  spids=""
  #b=0
  #for i in `seq 0 ${y}`; do
  #  a=${addresses[$i]}
  #  ssh roott@${a} 'bash -s' < 
  ./runWorkloadTestWatDiv.sh ${k} ${t}-client-eval ${n} ${c}  > outputRunTestWorkloadWatDiv_${t}_${b}_${c} &
  pid=$!
  spids="$spids $pid"
  #b=$(($b+1))
  #done

  for i in $spids; do
    wait $i
  done
done

for t in ${techniques}; do
  rm ${resultsFolder}/res_${t}_${e}.csv
  for l in `seq 0 ${u}`; do
    #i=$(($l % 2))
    #a=${addresses[$i]}
    cp /home/roott/vm11/Client.js-brTPF/eval_${t}_${k}.csv ${resultsFolder}/
    cat ${resultsFolder}/eval_${t}_${k}.csv >> ${resultsFolder}/res_${t}_${e}.csv
    k=$(($k+1))
  done
  ./processOutput.sh ${resultsFolder}/res_${t}_${e}.csv
done

#./deleteOutputs.sh

