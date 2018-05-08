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
# Default Configuration
##################################################################################
#get mongos port
mongos_port=$[ config_port+5 ]
#
mongos --configdb cfgReplSet/$server_1_ip:$config_port,$server_2_ip:$config_port,$server_3_ip:$config_port --port 22005 --logpath /home/mongodb/mongos/log/mongos.log --fork

ps -ef|grep mongo
