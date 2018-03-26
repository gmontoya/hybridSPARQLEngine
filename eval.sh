#!/bin/bash

timeoutMin=$4
maxNumMappings=$5
threshold=$6
endpoint=$7

e=""
t=""
m=""
o=""

if [ -n "${endpoint}" ]; then
  e="--endpointUrl ${endpoint}"
fi

if [ -n "${threshold}" ]; then
  t="--threshold ${threshold}"
fi

if [ -n "${maxNumMappings}" ]; then
  m="--maxNumberOfMappings ${maxNumMappings}"
fi

if [ -n "${timeoutMin}" ]; then
  o="--timeoutInMins ${timeoutMin}"
fi

timeoutMin=$(($timeoutMin+1))

for query in $3/*.rq
do
	echo $query
	echo "timeout ${timeoutMin}m ./bin/$1 -c $2 $query ${t} ${e} ${m} ${o}"
	results=$(timeout ${timeoutMin}m ./bin/$1 -c $2 $query ${t} ${e} ${m} ${o})
	echo "$results"
done
