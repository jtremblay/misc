#!/bin/sh
## output the CPU usage from MOAB

echo -e "------------------------------"
echo -e "Running job CPU usage per user\n------------------------------\nUser\tCPU#"
showq -r | grep -v "processors\|USERNAME" | awk ' {if ($7 != "") {print $7 "\t" $10}} ' | sort -k1,1 | awk ' NR==1{nam=$1;num=$2} NR>1 {if ($1 != nam) {print nam " : " num;nam=$1;num=$2} else {num=num+$2}} END {print nam " : " num} ' | sort -k3,3nr

echo -e "\n------------------------------"
echo -e "Idle job CPU usage per user\n------------------------------\nUser\tCPU#"
showq -i | grep -v "processors\|USERNAME" | awk ' {if ($5 != "") {print $5 "\t" $7}} ' | sort -k1,1 | awk ' NR==1{nam=$1;num=$2} NR>1 {if ($1 != nam) {print nam " : " num;nam=$1;num=$2} else {num=num+$2}} END {print nam " : " num} ' | sort -k3,3nr

