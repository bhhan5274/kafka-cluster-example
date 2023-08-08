#!/bin/sh

set -e

sudo yum update -y

# Java Install
sudo yum install -y java-11-amazon-corretto

# Work Path
cd /

# Zookeeper Install
sudo wget https://dlcdn.apache.org/zookeeper/zookeeper-3.8.2/apache-zookeeper-3.8.2-bin.tar.gz
sudo tar zxf apache-zookeeper-3.8.2-bin.tar.gz
ln -s apache-zookeeper-3.8.2-bin zookeeper

# EFS Path Mount
sudo mkdir -p /${efs_mount_point}
sudo yum -y install amazon-efs-utils
sudo su -c  "echo '${file_system_id}:/ /${efs_mount_point} efs _netdev,tls 0 0' >> /etc/fstab"
sudo mount /${efs_mount_point}
df -k

# Register Host
sudo bash -c "cat <<EOF >> /etc/hosts
${server_1} bhhan-1
${server_2} bhhan-2
${server_3} bhhan-3
EOF"

# Settings Config / Download Node Exporter
if [ ! -d /${efs_mount_point}/${server_name} ]; then
echo "Make Zookeeper Node Directory"
sudo mkdir -p /${efs_mount_point}/${server_name}
sudo bash -c "cat <<EOF > /${efs_mount_point}/${server_name}/myid
${server_name}
EOF"
fi

sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-386.tar.gz
sudo tar -xvf node_exporter-1.5.0.linux-386.tar.gz
ln -s node_exporter-1.5.0.linux-386 node_exporter

sudo bash -c "cat <<EOF > /zookeeper/conf/zoo.cfg
tickTime = 2000
initLimit = 40
syncLimit = 10
dataDir = /${efs_mount_point}/${server_name}
clientPort = 2181
server.1 = bhhan-1:2888:3888
server.2 = bhhan-2:2888:3888
server.3 = bhhan-3:2888:3888
metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
metricsProvider.httpHost=0.0.0.0
metricsProvider.httpPort=7000
metricsProvider.exportJvmInfo=true
EOF"

# Register Service / Node Exporter
sudo bash -c "cat <<EOF > /etc/systemd/system/zookeeper.service
[Unit]
Description=zookeeper service
After=network.target

[Service]
Type=forking
User=root
Group=root
SyslogIdentifier=zookeeper
ExecStart=/zookeeper/bin/zkServer.sh start
ExecStop=/zookeeper/bin/zkServer.sh stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF"

sudo bash -c "cat <<EOF > /etc/systemd/system/node-exporter.service
[Unit]
Description=Node Exporter
After=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/node_exporter/node_exporter
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload
sudo systemctl start node-exporter.service
sudo systemctl start zookeeper.service
echo "Zookeeper Server Started"
