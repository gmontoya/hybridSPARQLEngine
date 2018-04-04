#!/bin/bash

queryAnswer=$1
##groundTruth=$2
c=1.00
s=1.00

removeSpaces() {
  str="$1"
  while [ true ]; do
    strLen=${#str} 
    str=`echo $str | sed -e 's/} \+}/}}/g'` 
    newStrLen=${#str} 
    if [ $strLen -eq $newStrLen ]; then
      break
    fi
  done 
  echo "$str"
}

fixJSONFile() {
   file=$1
   #echo "file: $file"
   echo "" >> $file
   n=`wc -l $file | sed 's/^[ ^t]*//' | cut -d' ' -f1`
   #echo "n: $n"
   line=`head -n $n $file | tail -n 1 | tr -d ' '`
   #echo "line before removeSpaces: $line"
   line=`removeSpaces "$line"`
   #echo "fixing json file"
   #echo "line $line"
   while [[ "$line" != *"}}"* ]] || [ "${#line}" -lt 5 ]; do
       if [ $n -lt 2 ]; then
           break
       fi
       n=$(($n-1))
       l=`head -n $n $file | tail -n 1 | tr -d ' '`
       line="${l}${line}"
       line=`removeSpaces "$line"`
       #echo "line $line"
   done
   endStr="}}"
   if [[ "$line" != *"}}]"*"}}" ]]; then 
       echo "last line is not right: $line"
       echo "n: $n"
       if [ $n -gt 1 ]; then
           #echo "there is enough data"
           line="${line%$endStr*}"
           n=$(($n-1))
           head -n $n $file > $tmpFile
           line="${line}}}]}}"
           echo "$line" >> $tmpFile
           #cat $tmpFile
           mv $tmpFile $file
       else
           echo "{ \"results\" : { \"bindings\" : [ ] } }" > $tmpFile
           mv $tmpFile $file
       fi
   fi
}

tmpFile=`mktemp`

# clean the json file from incomplete results if needed..
fixJSONFile "$queryAnswer"

#echo "fixed file"

#cat "$queryAnswer"

# take just the bindings var value
python formatJSONFile.py $queryAnswer > $tmpFile
echo "$tmpFile"

##mv  $tmpFile $queryAnswer 
#echo "formated file"
#cat "$queryAnswer"

##./computeCompletenessSoundness.sh $queryAnswer $groundTruth
