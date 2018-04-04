#!/bin/bash

timeoutMin=$4
maxNumMappings=$5
threshold=$6
endpoint=$9
number=$7
countBytes=$8

e=""
t=""
m=""
o=""
n=""
c=""

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

if [ -n "${countBytes}" ]; then
  c="--countBytes ${countBytes}"
fi

timeoutMin=$(($timeoutMin+1))

for query in $3/*.rq
do
	echo $query
	echo "timeout ${timeoutMin}m ./bin/$1 -c $2 $query ${t} ${e} ${m} ${o} ${n} ${c}"
	results=$(timeout ${timeoutMin}m ./bin/$1 -c $2 $query ${t} ${e} ${m} ${o} ${n} ${c})
	echo "$results"
done
