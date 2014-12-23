#
## ELK stack
#
#  0.0.2 : 2014.09.02
#        - adopted concept of shared configuration and data via docker host
#          and based on that Docker file and sequential scripts are comprised
#
#  0.0.1 : 2014.08.28
#        - initial Dockerfile comprised from various sources
#
##


FROM ubuntu:14.04
MAINTAINER Milan Uremovic <milan.uremovic@gmail.com>

 
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu trusty-updates universe' >> /etc/apt/sources.list && \
    apt-get update

# Install utilities
RUN \
  apt-get install -y wget vim curl

# Install supervisord
RUN \
  apt-get install -y supervisor && \
  mkdir -p /var/log/supervisor
# CMD ["/usr/bin/supervisord", "-n"]



# Install OpenSSH server.
RUN \
  apt-get install -y openssh-server

#Install Oracle Java 7
RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' > /etc/apt/sources.list.d/java.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer

# Install Java.
# RUN \
#   apt-get install -y openjdk-7-jdk && \
#   rm -rf /var/lib/apt/lists/*
# 
# 
# # Install Java
# RUN apt-get install -yq \
#     openjdk-7-jre-headless \
#     wget


# Install ElasticSearch.
RUN \
  cd /tmp && \
  wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.tar.gz && \
  tar xvzf elasticsearch-1.3.2.tar.gz && \
  rm -f elasticsearch-1.3.2.tar.gz && \
  mv /tmp/elasticsearch-1.3.2 /opt/elasticsearch && \
# Plugin - Head
  /opt/elasticsearch/bin/plugin -install mobz/elasticsearch-head


# Download version 1.4.2 of logstash
RUN \
    cd /tmp && \
    wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz && \
    tar -xzvf ./logstash-1.4.2.tar.gz && \
    mv ./logstash-1.4.2 /opt/logstash && \
    rm ./logstash-1.4.2.tar.gz

# Plugin - GeoIP
RUN \
    cd /tmp && \
    wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && \
    gunzip GeoLiteCity.dat.gz && \
    mkdir -p /opt/repo/geoip && \
    mv GeoLiteCity.dat /opt/repo/geoip/GeoLiteCity.dat


#Kibana
RUN \
    cd /tmp && \
    wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz && \
    tar -zxvf kibana-*.tar.gz && \
    rm kibana-*.tar.gz && \
    mv kibana-* /opt/kibana


# Install Nginx.
RUN echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" > /etc/apt/sources.list.d/nginx-stable-trusty.list
RUN echo "deb-src http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list.d/nginx-stable-trusty.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
RUN apt-get update
RUN apt-get install -y  nginx
RUN rm -rf /var/lib/apt/lists/* 


# Add and initiate configurations and first run script
ADD ./ /tmp/elk
WORKDIR /tmp/elk
RUN mkdir -p /app
RUN mv app-elk.sh /app
RUN mv elk-init.sh /app
RUN chmod 0755 /app/app-elk.sh
RUN chmod 0755 /app/elk-init.sh


# Define mountable directories.
VOLUME ["/data"]

# Define working directory.
WORKDIR /data


#80=ngnx, 9200=elasticsearch, 49021=logstash, 49022=lumberjack, 9999=udp
EXPOSE 22 80 9200 9300 5514 


ENTRYPOINT ["/app/app-elk.sh"]

## Running it...
#
# # To get all the /dev/* devices needed for sshd and alike:
# export DEV_MOUNTS="-v /dev/null:/dev/null -v /dev/urandom:/dev/urandom -v /dev/random:/dev/random"
# export DEV_MOUNTS="${DEV_MOUNTS} -v /dev/full:/dev/full -v /dev/zero:/dev/zero"
# export DATA_VOLUME="-v /data:/data"
# 
# docker run -t -i ${DEV_MOUNTS} ${DATA_VOLUME} \
#            -p 8822:22 -p 8880:80 -p 89201:9200 \
#            punkto0/elk /bin/bash
# 
