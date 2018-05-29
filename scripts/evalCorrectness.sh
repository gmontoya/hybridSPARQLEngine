#!/bin/bash

timeoutMin=$4
maxNumMappings=$5
threshold=$6
endpoint=$9
number=$7
countBytes=$8
answerFolder=${10}

groundTruthFolder=${11}

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
	tmpFile=`mktemp`
	tmpJSON=`mktemp`
	tmpOut=${answerFolder}/$(basename $query)_$1
	#echo $query
	#echo "timeout ${timeoutMin}m ./bin/$1 -c $2 $query ${t} ${e} ${m} ${o} ${n} ${c}"
	#echo "{ \"results\" : { \"bindings\" : $(timeout ${timeoutMin}m ./bin/$1 -c $2 $query ${t} ${e} ${m} ${o} ${n} ${c}) } }" > "$tmpFile"
	#echo "output produced in $tmpFile"
	#scripts/processJSONAnswer.sh "$tmpFile" > "$tmpJSON"
	#echo "output JSON in $tmpJSON"
	result=$(timeout ${timeoutMin}m ../bin/$1 -c $2 $query ${t} ${e} ${m} ${o} ${n} ${c})
	result=${result//\"\?/\"}
	result=${result//\\\"/}
	#echo "{ \"results\" : { \"bindings\" : $result } }"
	echo "{ \"results\" : { \"bindings\" : $result } }" > "$tmpFile"
	#echo "output produced in $tmpFile"
	#echo $(python formatJSONFile.py $tmpFile)
	python formatJSONFile.py $tmpFile > "$tmpJSON"
	#echo "output JSON in $tmpJSON"
	LANG=En_US sort "$tmpJSON" > "$tmpOut"
	#LANG=En_US sort "$tmpJSON" > "outputCorrectness_$(basename $3)"
	rm $tmpFile
	rm $tmpJSON

	#echo "output in $tmpOut"
	#echo ./computeCompletenessSoundness.sh $tmpOut /home/roott/watDivQueries/answers/$(basename $3)/$(basename $query)
	echo "$(basename $query),$(./computeCompletenessSoundness.sh $tmpOut ${groundTruthFolder}/$(basename $query))"
	#mv $tmpOut
done
