#!/bin/bash

addresses="172.19.2.115 172.19.2.107 172.19.2.118 172.19.2.111"
b=0

for a in ${addresses}; do    
    ssh roott@${a} 'bash -s' < runWorkloadEndpoint.sh ${b} ${a} > outputRunWorkloadEndpoint_${a}_${b} &
    b=$(($b+1544))
done
