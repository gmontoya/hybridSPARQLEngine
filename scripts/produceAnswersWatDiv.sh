#!/bin/bash

qfolder=/home/roott/watdiv_queries/results
afolder=/home/roott/watdiv_queries/answers
hdtFile=/home/roott/datasets/watDiv10M/watdiv.10M.hdt

mkdir -p ${afolder}

for (( k=0; k<32; k++ ))
do
    mkdir -p ${afolder}/client_${k}
    ./produceAnswers.sh ${qfolder}/client_${k} ${hdtFile} 3030 ${afolder}/client_${k}
done
