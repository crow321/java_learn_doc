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
#
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

# 4.mongos节点配置
mkdir -p /home/mongodb/mongos/data
mkdir -p /home/mongodb/mongos/log

mongos --configdb $cfgReplSetName/$server_1_ip:$config_port,$server_2_ip:$config_port,$server_3_ip:$config_port --port $mongos_port --logpath /home/mongodb/mongos/log/mongos.log --fork

mongo localhost:$mongos_port <<EOF
use admin

db.runCommand( { addshard : "$shardReplSetName_1/$server_1_ip:$shard_1_port",name:"$shardReplSetName_1"} )

db.runCommand( { addshard : "$shardReplSetName_2/$server_2_ip:$shard_1_port",name:"$shardReplSetName_2"} )

db.runCommand( { addshard : "$shardReplSetName_3/$server_3_ip:$shard_1_port",name:"$shardReplSetName_3"} )

# 添加数据库 打开分片功能
use key_store

sh.enableSharding("key_store")

#增加集合
sh.shardCollection("key_store.statistics_info", {_id:"hashed"})
sh.shardCollection("key_store.service_key", {_id:"hashed"})
sh.shardCollection("key_store.quantum_key", {_id:"hashed"})
sh.shardCollection("key_store.random_digit", {_id:"hashed"})
sh.shardCollection("key_store.application_key", {_id:"hashed"})
sh.shardCollection("key_store.quantum_application_key", {_id:"hashed"})
sh.shardCollection("key_store.node_status", {_id:"hashed"})
#添加索引
db.node_status.ensureIndex({"userID":1,"createTime":-1})
db.quantum_key.ensureIndex({"nodeID":1,"keyState":1,"createTime":1})
db.application_key.ensureIndex({"owner":1,"createTime":1})
db.application_key.ensureIndex({"sessionID":1,"createTime":1})
db.application_key.ensureIndex({"sessionID":1})

sh.status();

exit
EOF

ps -ef|grep mongo