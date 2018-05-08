#!/bin/bash

#准备config节点（复制集形式，复制集名称为rs0）
mongod --dbpath /home/mongodb/config/data/ --logpath /home/mongodb/config/log/config.log --port 20004 --configsvr --replSet rs0 --fork

#启动shard数据节点 端口自定义
mongod --dbpath /home/mongodb/shard1/data --logpath /home/mongodb/shard1/log/shard1.log --shardsvr --port 20001 --fork
mongod --dbpath /home/mongodb/shard2/data --logpath /home/mongodb/shard2/log/shard2.log --shardsvr --port 20002 --fork
mongod --dbpath /home/mongodb/shard3/data --logpath /home/mongodb/shard3/log/shard3.log --shardsvr --port 20003 --fork 

#准备router节点（注意configdb采用复制集形式）
#注意连接时使用router节点即可
mongos --configdb rs0/localhost:20004 --logpath /home/mongodb/mongos/log/mongos.log --port 21000 --fork

