#!/bin/sh
cd /tmp
wget -O minecraft.jar "https://s3.amazonaws.com/Minecraft.Download/versions/$MINECRAFT_VER/minecraft_server.$MINECRAFT_VER.jar"
echo "eula=true" >> eula.txt
java -jar minecraft.jar
