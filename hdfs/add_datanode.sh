#!/bin/sh

count_params=$#

echo "$count_params"

for((i=0;i<$count_params;i++))
do
	argv[$i]=$1
	shift
done

echo ${argv[*]}

for((i=0;i<$count_params;i++))
do
	item=${argv[$i]}
	echo "173.17.2.$item	hdfs-dat-node-$item	hdfs-dat-node-$item" >> ./hosts
done

image="hdfs:hdp_base_1"

for((i=0;i<$count_params;i++))
do
	item=${argv[$i]}
	mkdir -p ${PWD}/hdfs_data/dat_$item
	docker run -d --rm -v ${PWD}/hadoop:/root/hadoop/ -v ${PWD}/config:/root/hadoop/etc/hadoop/ -v ${PWD}/hdfs_data/dat_$item:/root/tmp/ -w /root/hadoop/ --privileged -h hdfs-dat-node-$item --name hdfs_dat_node_$item --network hadoop --ip 173.17.2.$item -P ${image}
	cat hosts | docker exec -i hdfs_dat_node_$item tee -a /etc/hosts
done

