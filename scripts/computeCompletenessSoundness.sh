#!/bin/bash

queryAnswer=$1
groundTruth=$2
c=1.00
s=1.00

tmpFile=`mktemp`

# sort the bindings
LANG=En_US sort $queryAnswer > $tmpFile
mv $tmpFile $queryAnswer

# compute completeness and soundness
N=`wc -l $groundTruth | sed 's/^[ ^t]*//' | cut -d' ' -f1`
n=`wc -l $queryAnswer | sed 's/^[ ^t]*//' | cut -d' ' -f1`

if [ $N -eq 0 ]; then
  c=1.00
  if [ $n -eq 0 ]; then
    s=1.00
  else
    s=0.00
  fi
else
  if [ $n -eq 0 ]; then
    s=1.00
    c=0.00
  else
    IntersectionSize=`LANG=En_US comm -12 $queryAnswer $groundTruth | wc -l | sed 's/^[ ^t]*//' | cut -d' ' -f1`
    s=`echo "scale=2; $IntersectionSize/$n" | bc`
    c=`echo "scale=2; $IntersectionSize/$N" | bc`
  fi
fi

echo "$c,$s"

