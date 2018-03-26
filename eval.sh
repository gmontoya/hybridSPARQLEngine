#!/bin/bash

timeoutMin=$4
maxNumMappings=$5
threshold=$6
endpoint=$7

e=""
t=""
m=""

if [ -n "${endpoint}" ]; then
  e="--endpointUrl ${endpoint}"
fi

if [ -n "${threshold}" ]; then
  t="--threshold ${threshold}"
fi

if [ -n "${maxNumMappings}" ]; then
  m="--maxNumberOfMappings ${maxNumMappings}"
fi

for query in $3/*.rq
do
	echo $query
	echo "timeout ${timeoutMin}m ./bin/$1 -c $2 $query ${t} ${e} ${m}"
	results=$(timeout ${timeoutMin}m ./bin/$1 -c $2 $query ${t} ${e} ${m})
	echo "$results"
done
