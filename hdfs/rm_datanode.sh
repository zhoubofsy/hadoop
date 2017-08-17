#!/bin/sh

argc=$#

for((i=0;i<$argc;i++))
do
	argv[$i]=$1
	shift
done

echo ${argv[*]}

for((i=0;i<$argc;i++))
do
	item=${argv[$i]}
	echo "$item"
	sed -i "/^173.17.2.$item/d" ./hosts
	#e="'/^173.17.2.$item/d'"
	#echo $e
	#`sed $e ./hosts`
	echo "$?"
done

