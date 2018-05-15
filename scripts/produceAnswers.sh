#!/bin/bash

queriesFolder=$1
hdtFile=$2
localPort=$3
answersFolder=$4
tmpFile=`mktemp`

cd /home/roott/hdt/hdt-java/hdt-fuseki
bin/hdtEndpoint.sh --localhost --port=${localPort} --hdt=$hdtFile /ds > /dev/null &
pid=$!
sleep 10

for query in `ls $queriesFolder`; do
    if [ ! -f $answersFolder/${query} ]; then
        cd /home/roott/apache-jena-2.13.0/bin
        ./rsparql --service=http://127.0.0.1:${localPort}/ds/query --file=${queriesFolder}/${query} --results=JSON > "$answersFolder/${query}"
        cd /home/roott/brTPF/Client.js-brTPF/scripts
        python formatJSONAnswerFuseki.py "$answersFolder/${query}" > "$tmpFile"
        LANG=En_US sort "$tmpFile" > "$answersFolder/${query}"
    fi
done

pkill -P $pid
rm $tmpFile

