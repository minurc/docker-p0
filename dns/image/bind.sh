#!/bin/bash
set -e

mkdir -p /data

# generate a password for root.
ROOT_PASSWORD=$(dd if=/dev/urandom count=1 bs=12|xxd -ps)
echo "root:$ROOT_PASSWORD" | chpasswd
echo User: root Password: $ROOT_PASSWORD

chmod 775 /data

# create directory for bind config
mkdir -p /data/bind
chown -R root:bind /data/bind

# populate default bind configuration if it does not exist
if [ ! -d /data/bind/etc ]; then
  mv /etc/bind /data/bind/etc
fi
rm -rf /etc/bind
ln -sf /data/bind/etc /etc/bind

if [ ! -d /data/bind/lib ]; then
  mkdir -p /data/bind/lib
  chown root:bind /data/bind/lib
fi
rm -rf /var/lib/bind
ln -sf /data/bind/lib /var/lib/bind



echo "Starting named..."
mkdir -m 0775 -p /var/run/named
chown root:bind /var/run/named
exec /usr/sbin/named -u bind -g
