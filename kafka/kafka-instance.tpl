#!/bin/sh

set -e

sudo yum update -y

# Java Install
sudo yum install -y java-11-amazon-corretto

# Work Path
cd /

# EBS Settings And Mount
sudo vgchange -ay

if [ "`blkid -o value -s TYPE ${device}`" == "" ]; then
  sudo pvcreate ${device}
  sudo vgcreate ${vg} ${device}
  sudo lvcreate --name ${lv} -l 100%FREE ${vg}
  sudo mkfs.xfs /dev/${vg}/${lv}
fi

sudo mkdir -p /${data_path}
sudo echo "/dev/${vg}/${lv} /${data_path} xfs defaults 0 0" | sudo tee -a /etc/fstab > /dev/null
sudo mount /dev/${vg}/${lv} /${data_path}

# Kafka Install
sudo wget https://archive.apache.org/dist/kafka/2.8.0/kafka_2.12-2.8.0.tgz
sudo tar -xvf kafka_2.12-2.8.0.tgz
sudo ln -s kafka_2.12-2.8.0 kafka

# EFS Path Mount
sudo mkdir -p /${efs_mount_point}
sudo yum -y install amazon-efs-utils
sudo su -c  "echo '${file_system_id}:/ /${efs_mount_point} efs _netdev,tls 0 0' >> /etc/fstab"
sudo mount /${efs_mount_point}
df -k

# Register Environment Variables / Configuration
#sudo echo "export KAFKA_HEAP_OPTS='-Xmx${heap_size} -Xms${heap_size}'" | sudo tee -a ~/.bashrc > /dev/null
#sudo echo "export JMX_PORT=9999" | sudo tee -a ~/.bashrc > /dev/null
#source ~/.bashrc
sudo bash -c "cat <<EOF > /etc/kafka-env
KAFKA_HEAP_OPTS='-Xmx${heap_size} -Xms${heap_size}'
JMX_PORT=9999
KAFKA_JMX_OPTS='-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.rmi.port=9999 -Djava.rmi.server.hostname=${kafka_ip}'
EOF"

sudo sed -i "s/broker.id=0/broker.id=${number}/g" /kafka/config/server.properties
sudo sed -i "s/offsets.topic.replication.factor=1/offsets.topic.replication.factor=3/g" /kafka/config/server.properties
sudo sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=${zookeeper_address}/g" /kafka/config/server.properties
sudo sed -i "s/zookeeper.connection.timeout.ms=6000/zookeeper.connection.timeout.ms=10000/g" /kafka/config/server.properties
sudo sed -i "s/log.dirs=\/tmp\/kafka-logs/log.dirs=\/${data_path}/g" /kafka/config/server.properties

sudo bash -c "cat <<EOF >> /kafka/config/server.properties
delete.topic.enable=true
default.replication.factor=3
min.insync.replicas=2
auto.create.topics.enable=false
unclean.leader.election.enable=true
advertised.listeners=PLAINTEXT://${kafka_ip}:9092
EOF"

#Node Exporter Download
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-386.tar.gz
sudo tar -xvf node_exporter-1.5.0.linux-386.tar.gz
ln -s node_exporter-1.5.0.linux-386 node_exporter

#JMX Exporter Download
sudo wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_httpserver/0.19.0/jmx_prometheus_httpserver-0.19.0.jar
sudo mv jmx_prometheus_httpserver-0.19.0.jar /etc/jmx_exporter.jar
sudo chmod +x /etc/jmx_exporter.jar

sudo bash -c "cat <<EOF > /etc/jmx.yml
hostPort: 127.0.0.1:9999
ssl: false
rules:
  - pattern: \".*\"
EOF"

#Kafka Exporter Download
sudo wget https://github.com/danielqsj/kafka_exporter/releases/download/v1.3.2/kafka_exporter-1.3.2.linux-386.tar.gz
sudo tar -xvf kafka_exporter-1.3.2.linux-386.tar.gz
sudo mv kafka_exporter-1.3.2.linux-386/kafka_exporter /etc/kafka_exporter

# Register Service / Node Exporter / JMX Exporter / Kafka Exporter
sudo bash -c "cat <<EOF > /etc/systemd/system/kafka.service
[Unit]
Description=kafka service
After=network.target

[Service]
Type=simple
User=root
Group=root
LimitNOFILE=16384
SyslogIdentifier=kafka
EnvironmentFile=/etc/kafka-env
ExecStart=/kafka/bin/kafka-server-start.sh /kafka/config/server.properties
ExecStop=/kafka/bin/kafka-server-stop.sh
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

sudo bash -c "cat <<EOF > /etc/systemd/system/jmx-exporter.service
[Unit]
Description=jmx exporter service
After=kafka.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/bin/java -jar /etc/jmx_exporter.jar 7071 /etc/jmx.yml
Restart=always

[Install]
WantedBy=multi-user.target
EOF"

sudo bash -c "cat <<EOF > /etc/systemd/system/kafka-exporter.service
[Unit]
Description=kafka exporter service
After=kafka.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/etc/kafka_exporter --kafka.server=localhost:9092
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload
sudo systemctl start kafka.service
sudo systemctl start node-exporter.service
sudo systemctl start jmx-exporter.service
sudo systemctl start kafka-exporter.service
