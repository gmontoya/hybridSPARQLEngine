#!/bin/bash

tmpFile=`mktemp`
file=$1

grep -v ERROR ${file} > ${tmpFile}
rm ${file}

while read line; do
    l=`echo ${line%%,TIMEOUT*}`
    x=`echo ${l##*/}`
    n=`echo ${x%%,*}`
    r=`echo ${x#*,}`
    n=`echo ${n%%.rq}`
    n=`echo ${n##query}`
    echo "q${n},${r}" >> ${file}
done < ${tmpFile}
