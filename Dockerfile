#Download base image
FROM arm64v8/debian:buster-slim

#Set default timezone
ENV TIME_ZONE=America/Los_Angeles
ENV DIST_UPDATE=0
ENV TS_UPDATE=0
ENV TS_UPDATE_BACKUP=1
ENV UID=1000
ENV GID=1000
ENV INIFILE=0
ENV DEBUG=0
ENV QEMU_OFFSET=0x8000
ENV TS_ARCHITECTURE=x86
ENV SYSTEM_ARCHITECTURE=arm
ENV EMULATOR=qemu

#Accept the TS3Server License
ENV TS3SERVER_LICENSE accept

LABEL Maintainer="ertagh@web.de"

#Add s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-aarch64.tar.gz /tmp/

#Update repository and install necessary programs
#Creating folders
#untar s6
#Set locale
RUN echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -t buster-backports -y qemu qemu-user wget bzip2 procps jq iputils-ping curl libdigest-sha-perl ca-certificates locales && \
    mkdir /lib/i386-linux-gnu && \
    mkdir /teamspeak && \
    mkdir /teamspeak/sh && \
    mkdir /teamspeak_cached && \
    tar xzf /tmp/s6-overlay-aarch64.tar.gz -C / && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8 

#Setting Workdir
WORKDIR /teamspeak

#Let's copy the data and chmod them
#Clean the system
#Set the timezone
#Certificates
COPY root/ /
RUN chmod +x /teamspeak/sh/check_update.sh /teamspeak/sh/functions.sh /teamspeak/sh/recovery.sh /teamspeak/sh/update.sh /teamspeak/recover.sh /teamspeak/sh/startup.sh /teamspeak/sh/helper.sh && \
    chmod 644 /lib/ld-linux.so.2 && \
    chmod -R 644 /lib/i386-linux-gnu && \
    chmod 755 /lib/i386-linux-gnu && \
    apt-get autoremove -y && \
    apt-get clean && \
    ln -fs /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    wget -O /usr/local/share/ca-certificates/certificates.crt "https://curl.haxx.se/ca/cacert.pem" > /dev/null 2>&1 && \
    update-ca-certificates

#Set the entrypoint
ENTRYPOINT [ "/init" ]
