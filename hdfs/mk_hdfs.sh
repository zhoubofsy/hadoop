#!/bin/sh

master_count=$1
slave_count=$2

echo "$master_count"
echo "$slave_count"

echo "" > ./hosts

for((i=1;i<=$master_count;i++))
do
	echo "192.168.1.$i    master-node-$i    master-node-$i" >> ./hosts
done

for((i=1;i<=$slave_count;i++))
do
	echo "192.168.2.$i    slave-node-$i    slave-node-$i" >> ./hosts
done

master_cmd="top"
# create master nodes
for((i=1;i<=$master_count;i++))
do
	docker run -d --rm -v ${PWD}/hadoop-2.7.3:/root/hadoop/ -w /root/hadoop/ --privileged -h master-node-$i --name master_node_$i --network hadoop --ip 192.168.1.$i hadoop_base:centos7.3.1611 $master_cmd
	cat hosts | docker exec -i master_node_$i tee -a /etc/hosts
done

# create slave nodes
slave_cmd="top"
for((i=1;i<=$slave_count;i++))
do
	docker run -d --rm -v ${PWD}/hadoop-2.7.3:/root/hadoop/ -w /root/hadoop/ --privileged -h slave-node-$i --name slave_node_$i --network hadoop --ip 192.168.2.$i hadoop_base:centos7.3.1611 $slave_cmd
	cat hosts | docker exec -i slave_node_$i tee -a /etc/hosts
done


rm -vf ./hosts
