#!/bin/bash

cd /tmp
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
rpm -ivh jdk-17_linux-x64_bin.rpm
mkdir /opt/minecraft_server
cd /opt/minecraft_server
wget https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar
java -Xmx1024M -Xms1024M -jar server.jar nogui
sed -i 's/eula=false/eula=true/' eula.txt
java -Xmx1024M -Xms1024M -jar server.jar nogui