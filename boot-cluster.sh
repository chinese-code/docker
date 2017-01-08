
#!/bin/bash
public_ip=`ifconfig enp0s5 | grep inet | grep -v inet6 | awk '{print $2}'`
docker rm -f `docker ps -a -q`
cd composefile
#启动 vpn和dns
docker-compose -f dns-vpn-compose.yml up -d
#启动mysql
#docker-compose -f mysql-compose.yml up -d
#启动zookeeper
docker-compose -f zookeeper-compose.yml up -d
#启动journalnode
docker-compose -f hadoop-journalnode-compose.yml up -d
echo "puase 60s,wait service: vpn,dns,mysql,zookeeper,journalnode starting......"
sleep 60
echo "===============cluster.znode1.server status================="
echo stat |nc 172.18.0.221 2181
echo "===============cluster.znode2.server status================="
echo stat |nc 172.18.0.222 2181
echo "===============cluster.znode3.server status================="
echo stat |nc 172.18.0.223 2181
#启动namenode1,namenode2
docker-compose -f hadoop-namenode-compose.yml create
docker start cluster.namenode1.server
sleep 10
docker start cluster.namenode2.server
echo "puase 60s,wait service: namenode1,namenode2 staring...."
sleep 10
docker start cluster.extramanager.server
sleep 10
#启动datanode
docker-compose -f hadoop-datanode-compose.yml create
docker start cluster.datanode1.server
docker start cluster.datanode2.server
sleep 15
#启动hbase
#docker-compose -f hbase-compose.yml up -d
