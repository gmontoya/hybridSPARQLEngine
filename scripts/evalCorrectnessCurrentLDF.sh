#!/bin/bash

timeoutMin=$4
answerFolder=${5}
groundTruthFolder=${6}

timeoutMin=$(($timeoutMin+1))

for query in $3/*.rq
do
        tmpFile=`mktemp`
        tmpJSON=`mktemp`
        tmpOut=${answerFolder}/$(basename $query)_$1
        result=$(timeout ${timeoutMin}m /home/roott/ldf/Client.js/bin/$1 $2 $query)
        result=${result//\"\?/\"}
        result=${result//\\\"/}
        echo "{ \"results\" : { \"bindings\" : $result } }" > "$tmpFile"
        python formatJSONFile.py $tmpFile > "$tmpJSON"
        LANG=En_US sort "$tmpJSON" > "$tmpOut"
        rm $tmpFile
        rm $tmpJSON

        echo "$(basename $query),$(./computeCompletenessSoundness.sh $tmpOut ${groundTruthFolder}/$(basename $query))"
done
