#!/bin/sh

zk_count=$1

echo "$zk_count"

mkdir -p ./zkdata
echo "" > ./hosts

for((i=0,j=1;i<$zk_count;i++,j++))
do
	echo "173.17.3.$j    zoo-$i    zoo-$i" >> ./hosts
	mkdir -p ./zkdata/zoo-$i
	echo "$i" > ./zkdata/zoo-$i/myid
done

image="zk:hdp_base_1"
# create zk nodes
for((i=0,j=1;i<$zk_count;i++,j++))
do
	docker run -d --rm -v ${PWD}/zookeeper:/root/zookeeper/ -v ${PWD}/zkdata/zoo-$i:/root/zkdata/ -w /root/ --privileged -h zoo-$i --name zoo_$i --network hadoop --ip 173.17.3.$j -P ${image}
	cat hosts | docker exec -i zoo_$i tee -a /etc/hosts
done

rm -vf ./hosts

