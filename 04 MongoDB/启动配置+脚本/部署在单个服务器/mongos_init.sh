#!/bin/bash

echo `pwd`
#创建目录
mkdir -p /home/mongodb/mongos/data
mkdir -p /home/mongodb/mongos/log
mkdir -p /home/mongodb/shard1/data
mkdir -p /home/mongodb/shard1/log
mkdir -p /home/mongodb/shard2/data
mkdir -p /home/mongodb/shard2/log
mkdir -p /home/mongodb/shard3/data
mkdir -p /home/mongodb/shard3/log
mkdir -p /home/mongodb/config/data
mkdir -p /home/mongodb/config/log
#启动shard数据节点 端口自定义
mongod --dbpath /home/mongodb/shard1/data --logpath /home/mongodb/shard1/log/shard1.log --shardsvr --port 20001 --fork
mongod --dbpath /home/mongodb/shard2/data --logpath /home/mongodb/shard2/log/shard2.log --shardsvr --port 20002 --fork
mongod --dbpath /home/mongodb/shard3/data --logpath /home/mongodb/shard3/log/shard3.log --shardsvr --port 20003 --fork 
#准备config节点（复制集形式，复制集名称为rs0）
mongod --dbpath /home/mongodb/config/data/ --logpath /home/mongodb/config/log/config.log --port 20004 --configsvr --replSet rs0 --fork
mongo localhost:20004 <<EOF
use admin
cfg = {
...     _id:'rs0',
...     configsvr:true,
...     members:[
...         {_id:0,host:'localhost:20004'}
...      ]
... };
rs.initiate(cfg);
exit
EOF
#准备router节点（注意configdb采用复制集形式）
#注意连接时使用router节点即可
mongos --configdb rs0/localhost:20004 --logpath /home/mongodb/mongos/log/mongos.log --port 21000 --fork
#连接路由节点
mongo localhost:21000	<<EOF
sh.addShard('localhost:20001');
sh.addShard('localhost:20002');
sh.addShard('localhost:20003');
exit
EOF

#添加数据库启动分片测试 
mongo localhost:21000 <<EOF
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

exit

EOF
