#!/bin/bash

addresses="172.19.2.115 172.19.2.107 172.19.2.118 172.19.2.111"
techniques="brTPF hybrid endpoint"

for t in ${techniques}; do
  for a in ${addresses}; do
    ssh roott@${a} 'bash -s' < deleteOutput.sh "${t}" >> outputDeleteOutput${a} &
  done
done
