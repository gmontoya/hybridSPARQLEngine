#!/bin/bash

srcFolder=/home/roott/simpleQueryGenerator/queries
prefixFolder=/home/roott/simpleQueryGenerator/dbpedia_queries_

declare -a minis=(0 100 1000)
declare -a maxis=(100 1000 10000)
declare -a templates=("TP" "2STAR" "2PATH" "4STAR" "4PATH")

for i in `seq 0 4`; do
   t=${templates[$i]}
   for j in `seq 0 2`; do
     min=${minis[$j]}
     max=${maxis[$j]}
     for k in `seq 0 47`; do
       l=$(($k % 16))
       dir=$prefixFolder$l
       [[ -d "$dir" ]] || mkdir "$dir"
       cp ${srcFolder}/query_${t}_${min}_${max}_${k} ${dir}/query_${t}_${min}_${max}_${k}.rq
     done
  done
done

dstFolder=/home/roott/Client.js-brTPF/queries
declare -a addresses=("172.19.2.115" "172.19.2.107" "172.19.2.118" "172.19.2.111")

for l in `seq 0 15`; do
    i=$(($l % 4))
    a=${addresses[$i]}
    scp -r ${prefixFolder}${l} roott@${a}:${dstFolder}/dbpedia_queries_${l}
done
