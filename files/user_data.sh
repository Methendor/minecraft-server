#!/bin/bash

# download and install java
cd /tmp
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
rpm -ivh jdk-17_linux-x64_bin.rpm

# download minecraft server 19.2
mkdir ${mc_root}
cd ${mc_root}
wget https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar

# initial startup of minecraft server and agreeing to EULA
java -Xmx${java_mx_mem} -Xms${java_mx_mem} -jar server.jar nogui
sed -i 's/eula=false/eula=true/' eula.txt

# intial sync of the minecraft worlds
mkdir ${mc_worlds} 
aws s3 sync s3://${mc_bucket} ${mc_worlds}

# set up minecraft as a service
cat <<SYSTEMD > /etc/systemd/system/minecraft.service
[Unit]
Description=Minecraft Server
After=network.target
[Service]
Type=simple
User=root
WorkingDirectory=${mc_root}
ExecStart=/usr/bin/java -Xmx${java_mx_mem} -Xms${java_ms_mem} -jar server.jar nogui
Restart=on-abort
[Install]
WantedBy=multi-user.target
SYSTEMD

# set up cron job to sync minecraft world with save bucket
cat <<CRON > /etc/cron.d/minecraft
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:${mc_root}
*/${mc_backup_freq} * * * * root /usr/bin/aws s3 sync ${mc_worlds}  s3://${mc_bucket}
CRON

# add ops file
cat <<OPS > ${mc_root}/ops.json
[
    {
      "uuid": "bdc5db75-d1a5-4522-a66c-3b6aa0cb5e0b",
      "name": "Methendor",
      "level": 4,
      "bypassesPlayerLimit": false
    },
    {
      "uuid": "a46ae6aa-41db-45b3-9455-9badf7c41fbf",
      "name": "Tobysaurus13",
      "level": 4,
      "bypassesPlayerLimit": false
    }
]
OPS

# add boot script on instance reboot
cat <<BOOT > /var/lib/cloud/scripts/per-boot/minecraft-boot.sh
systemctl start minecraft
curl http://169.254.169.254/latest/meta-data/public-ipv4
BOOT
