#!/bin/bash
#
# 0.2 : 2014-09-03
#     - elastic search database separation from app container
#     - app initialization script app-elk.sh setup
#     - additional system setup (timezone, root access)
#
# 0.1 : 2014-09-02
#     - basic initialization of elk stack
#     - separation of elk data/config from application container
#
##

CONF="/data"

mkdir -p $CONF
mkdir -p $CONF/elasticsearch
mkdir -p $CONF/elasticsearch/logs
mkdir -p $CONF/elasticsearch/data
mkdir -p $CONF/logstash
mkdir -p $CONF/kibana
mkdir -p $CONF/nginx


# configure timezone
cp /usr/share/zoneinfo/Europe/Belgrade /etc/localtime
echo "Europe/Belgrade" > /etc/timezone

# configure root access over SSH
ROOT_PASSWORD=$(dd if=/dev/urandom count=1 bs=12|xxd -ps)
echo "root:$ROOT_PASSWORD" | chpasswd
echo User: root Password: $ROOT_PASSWORD

mkdir /var/run/sshd && chmod 700 /var/run/sshd
cd /etc/ssh && sed -i'' -e 's/^PermitRootLogin.*/PermitRootLogin yes/g' sshd_config


# Nginx
echo "daemon off;" >> /etc/nginx/nginx.conf
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.saved && \
   ln -s $CONF/nginx/nginx.conf /etc/nginx/nginx.conf 

cat >$CONF/nginx/nginx.conf << EOF_NGINX
daemon off;

events {
        worker_connections 256;
        # multi_accept on;
}

http {
    server {
      listen                *:80 ;

      server_name           kibana;
      access_log            /var/log/nginx/kibana.access.log;
      include               /etc/nginx/mime.types;

      location / {
        root  /opt/kibana;
        index  index.html  index.htm;
      }

    }
}
EOF_NGINX


# Supervisord
cat > /etc/supervisor/conf.d/supervisord-kibana.conf << EOF_SVC
[supervisord]
nodaemon=true

[program:sshd]
command=/usr/sbin/sshd -D
autorestart=true

[program:elasticsearch]
command=/opt/elasticsearch/bin/elasticsearch -f
autorestart=true

[program:nginx]
command=/usr/sbin/nginx
autorestart=true

[program:logstash]
stderr_logfile=/var/log/supervisor/supervisor_err.log
stdout_logfile=/var/log/supervisor/supervisor_out.log
command=/opt/logstash/bin/logstash -f $CONF/logstash/logstash.conf
autorestart=true
EOF_SVC


# Elasticsearch
mv /opt/elasticsearch/config $CONF/elasticsearch/ && \
   ln -s $CONF/elasticsearch/config /opt/elasticsearch/config

ln -s $CONF/elasticsearch/data /opt/elasticsearch/data

ln -s $CONF/elasticsearch/logs /opt/elasticsearch/logs



# Logstash

cat > $CONF/logstash/logstash.conf << EOF_LOGSTASH
input {
# tcp {
#     port => 5514
#     type => "syslog"
# }
# 
# udp {
#   port => 5514
#   type => "syslog"
# }

syslog {
    port => 5514
    type => "syslog"
}

}

filter {
}

output {
  elasticsearch { host => localhost }
}

EOF_LOGSTASH

# Kibana
mv /opt/kibana/config.js /opt/kibana/config.js.backup

cat >$CONF/kibana/config.js << EOF_KIBANA
define(['settings'],
function (Settings) {
  

  return new Settings({
    elasticsearch: "http://"+window.location.hostname+":49201",
    default_route     : '/dashboard/file/default.json',
    kibana_index: "kibana-int",

    panel_names: [
      'histogram',
      'map',
      'goal',
      'table',
      'filtering',
      'timepicker',
      'text',
      'hits',
      'column',
      'trends',
      'bettermap',
      'query',
      'terms',
      'stats',
      'sparklines'
    ]
  });
});
EOF_KIBANA


ln -s $CONF/kibana/config.js /opt/kibana/config.js



# # rSyslog forwarding to logstash
# cat >/etc/rsyslog.d/79-logstash.conf << EOF_RSYSLOG
# 
# *.*	@@127.0.0.1:5514
# 
# EOF_RSYSLOG
# service rsyslog restart






exit 0
