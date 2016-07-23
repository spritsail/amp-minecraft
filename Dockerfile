FROM adamant/amp-base

USER root

RUN echo "deb http://ftp.de.debian.org/debian jessie-backports main" >> /etc/apt/sources.list \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends openjdk-8-jre \
 && apt-get clean \
 && rm -rf /var/lib/apt /tmp/* /var/tmp/*

USER AMP

ENV MODULE=Minecraft EXTRAS="+MinecraftModule.Minecraft.PortNumber 25565 +MinecraftModule.Java.MaxHeapSizeMB 3072"

EXPOSE 8080 25565
