#!/bin/bash
folder=$1
endpointAddress=$2
timeoutMin=$3

for query in $folder/*.rq
do
    #echo $query
    #echo "timeout ${timeoutMin}m python sparql.py $query $endpointAddress"
    results=$(timeout ${timeoutMin}m python sparql.py $query $endpointAddress)
    echo "$results"
done
