#!/bin/bash

srcfolder=/home/roott/datasets/watDiv10M/watdiv_queries
dstfolder=/home/roott/watdiv_queries

addresses="172.19.2.115 172.19.2.107 172.19.2.118 172.19.2.111"
b=0
for a in ${addresses}; do
    ssh roott@${a} 'bash -s' < anotherScript.sh > outputCreateFolder${a} &
    sleep 3s
    for i in `seq 1 8`; do
        scp -r ${srcfolder}/watdiv_queries_${b} roott@${a}:${dstfolder}/watdiv_queries_${b}
        b=$(($b+193))
    done
done
