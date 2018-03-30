#!/bin/bash

timeoutMin=$4
maxNumMappings=$5
threshold=$6
endpoint=$8
number=$7

e=""
t=""
m=""
o=""
n=""

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

if [ -n "${number}" ]; then
  n="--outputFileNumber ${number}"
fi

timeoutMin=$(($timeoutMin+1))

for query in $3/*.rq
do
	echo $query
	echo "timeout ${timeoutMin}m ./bin/$1 -c $2 $query ${t} ${e} ${m} ${o} ${n}"
	results=$(timeout ${timeoutMin}m ./bin/$1 -c $2 $query ${t} ${e} ${m} ${o} ${n})
	echo "$results"
done
