#!/bin/bash
#
###############################################################################################
#	Configuration:
#		1.只需配置默认端口  config_port
#			Config Node 1 port: 22000
#			Shard Node 1 port :	22001
#			Shard Node 2 port :	22002
#			Shard Node 3 port :	22003
###############################################################################################
#
config_port=22000
#
###############################################################################################
ip=`ifconfig eth0 |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " " `
shardReplSetName=shardReplSet-$ip
cfgReplSetName=cfgReplSet

echo "localhost ip is $ip"

mkdir -p /home/mongodb/config/data
mkdir -p /home/mongodb/config/log

cd /home/mongodb/config/

for j in 1 2 3
    do
    mkdir -p /home/mongodb/shard$j/data
    mkdir -p /home/mongodb/shard$j/log

    #start shard
        shard_port=$[ config_port+j ]
        shard_name=shard$j
    mongod --shardsvr --replSet $shardReplSetName --port $shard_port --dbpath /home/mongodb/$shard_name/data --logpath /home/mongodb/$shard_name/log/$shard_name.log --fork
done
echo "------------------- start shard replSet complete -------------------"

# set shardReplSet
mongo $ip:$[ config_port+1 ] <<EOF
use admin

config = {_id: '$shardReplSetName', members: [
                          {_id: 0, host: '$ip:22001'},
                          {_id: 1, host: '$ip:22002'},
                          {_id: 2, host: '$ip:22003',"arbiterOnly":true}
             ]
        }

# 初始化配置
rs.initiate(config);

db.getMongo().setSlaveOk()

exit
EOF

#start config
mongod --configsvr --replSet $cfgReplSetName --port $config_port --dbpath /home/mongodb/config/data --logpath /home/mongodb/config/log/config.log --fork

#配置config server复制集
mongo $ip:$config_port <<EOF
use admin

config = {_id: '$cfgReplSetName',
                      configsvr:true,
                      members: [
                      {_id: 0, host: '$ip:$config_port'}
                  ]
          }

# 初始化配置
rs.initiate(config);

exit
EOF

ps -ef|grep mongo
