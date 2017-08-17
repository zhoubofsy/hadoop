#!/bin/sh

hb_count=$1

echo "$hb_count"

echo "" > ./hosts
echo "192.168.1.1    master-node-1    master-node-1" >> ./hosts
echo "192.168.3.1    zoo-0    zoo-0" >> ./hosts
echo "192.168.3.2    zoo-1    zoo-1" >> ./hosts
echo "192.168.3.3    zoo-2    zoo-2" >> ./hosts


echo -n "" > ${PWD}/hbase-1.2.6/conf/regionservers

for((i=1;i<=$hb_count;i++))
do
	echo "192.168.4.$i    hb-node-$i    hb-node-$i" >> ./hosts
	echo "hb-node-$i" >> ${PWD}/hbase-1.2.6/conf/regionservers
done

master_cmd="/usr/sbin/sshd -D"
image="hdfs:hadoop_base"
# create hbase nodes
for((i=1;i<=$hb_count;i++))
do
	docker run -d --rm -v ${PWD}/hbase-1.2.6:/root/hbase/ -e HBASE_MANAGES_ZK=false -e HBASE_LOG_DIR="/root/hbase/logs" -w /root/hbase/ --privileged -h hb-node-$i --name hb_node_$i --network hadoop --ip 192.168.4.$i -P ${image}
	cat hosts | docker exec -i hb_node_$i tee -a /etc/hosts
done


rm -vf ./hosts

