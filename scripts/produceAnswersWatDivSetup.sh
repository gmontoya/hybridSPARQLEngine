#!/bin/bash

qfolder=/home/roott/datasets/watDiv10M/watdiv_queries
afolder=/home/roott/datasets/watDiv10M/watdiv_answers
hdtFile=/home/roott/datasets/watDiv10M/watdiv.10M.hdt

mkdir ${afolder}

b=0
for k in `seq 1 32`; do
    mkdir ${afolder}/watdiv_queries_${b}
    ./produceAnswers.sh ${qfolder}/watdiv_queries_${b} ${hdtFile} 3030 ${afolder}/watdiv_queries_${b}
    b=$(($b+193))
done

dstfolder=/home/roott/watdiv_answers

addresses="172.19.2.115 172.19.2.107 172.19.2.118 172.19.2.111"
b=0
for a in ${addresses}; do
    ssh roott@${a} 'bash -s' < anotherScript.sh > outputCreateFolder${a} &
    sleep 3s
    for i in `seq 1 8`; do
        scp -r ${afolder}/watdiv_queries_${b} roott@${a}:${dstfolder}/watdiv_queries_${b}
        b=$(($b+193))
    done
done
