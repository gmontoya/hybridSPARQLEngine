#!/bin/bash

b=0
a=$1 # hybridTPF
folder=$2
n=$3
rm ${folder}/res_${a}.csv
for i in `seq 1 ${n}`; do
    cat ${folder}/eval_${a}_${b}.csv >> ${folder}/res_${a}.csv
    b=$(($b+193))
done
