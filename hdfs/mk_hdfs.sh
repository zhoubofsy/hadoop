#!/bin/sh

master_count=$1
slave_count=$2

zk_count=${3:-0}

echo "$master_count"
echo "$slave_count"
echo "$zk_count"

echo "" > ./hosts

for((i=0,j=1;i<$zk_count;i++,j++))
do
	echo "173.17.3.$j	zoo-$i	zoo-$i" >> ./hosts
done

for((i=1;i<=$master_count;i++))
do
	echo "173.17.1.$i    hdfs-nm-node-$i    hdfs-nm-node-$i" >> ./hosts
done

for((i=1;i<=$slave_count;i++))
do
	echo "173.17.2.$i    hdfs-dat-node-$i    hdfs-dat-node-$i" >> ./hosts
done

master_cmd="/usr/sbin/sshd -D"
master_image="hdfs:hdp_base_1"
# create master nodes
for((i=1;i<=$master_count;i++))
do
	mkdir -p ${PWD}/hdfs_data/nm_$i
	docker run -d --rm -v ${PWD}/hadoop:/root/hadoop/ -v ${PWD}/config:/root/hadoop/etc/hadoop/ -v ${PWD}/hdfs_data/nm_$i:/root/tmp/ -w /root/hadoop/ --privileged -h hdfs-nm-node-$i --name hdfs_nm_node_$i --network hadoop --ip 173.17.1.$i -P ${master_image}
	cat hosts | docker exec -i hdfs_nm_node_$i tee -a /etc/hosts
done

# create slave nodes
slave_cmd="/usr/sbin/sshd -D"
slave_image="hdfs:hdp_base_1"
for((i=1;i<=$slave_count;i++))
do
	mkdir -p ${PWD}/hdfs_data/dat_$i
	mkdir -p ${PWD}/hdfs_journal/$i
	docker run -d --rm -v ${PWD}/hadoop:/root/hadoop/ -v ${PWD}/config:/root/hadoop/etc/hadoop/ -v ${PWD}/hdfs_data/dat_$i:/root/tmp/ -v ${PWD}/hdfs_journal/$i:/root/journal/ -w /root/hadoop/ --privileged -h hdfs-dat-node-$i --name hdfs_dat_node_$i --network hadoop --ip 173.17.2.$i -P ${slave_image}
	cat hosts | docker exec -i hdfs_dat_node_$i tee -a /etc/hosts
done


rm -vf ./hosts
