#!/bin/bash
#
###############################################################################################
#	Configuration:
#		1.配置Shard ReplSet Node IP
#			server_1_ip、server_2_ip、server_3_ip	
#		2.配置默认端口（必须与shard_init.sh脚本中保持一致）	config_port
#		3.Mongos 路由节点端口为 config_port+5
#		连接mongo集群时将客户端指向 Mongos 即可，默认Mongos 地址: localhost:22005
###############################################################################################
#set mongo shards ip
server_1_ip=192.168.94.109
server_2_ip=192.168.94.108
server_3_ip=192.168.94.110
#set config port
config_port=22000
##################################################################################
#
##################################################################################
#set mongos port
mongos_port=$[ config_port+5 ]
#set other port
shard_1_port=$[ config_port+1 ]

#set shardReplSet name
shardReplSetName_1=shardReplSet-$server_1_ip
shardReplSetName_2=shardReplSet-$server_2_ip
shardReplSetName_3=shardReplSet-$server_3_ip

#set configReplSet name
cfgReplSetName=cfgReplSet
###############################################################################################
#first start configsvr
mongod --configsvr --replSet $cfgReplSetName --port $config_port --dbpath /home/mongodb/config/data --logpath /home/mongodb/config/log/config.log --fork
#then start shardsvr
mongod --shardsvr --replSet $shardReplSetName_1 --port $[ config_port+1 ] --dbpath /home/mongodb/shard1/data --logpath /home/mongodb/shard1/log/shard1.log --fork
mongod --shardsvr --replSet $shardReplSetName_2 --port $[ config_port+2 ] --dbpath /home/mongodb/shard2/data --logpath /home/mongodb/shard2/log/shard2.log --fork
mongod --shardsvr --replSet $shardReplSetName_3 --port $[ config_port+3 ] --dbpath /home/mongodb/shard3/data --logpath /home/mongodb/shard3/log/shard3.log --fork

ps -ef|grep mongo
