#!/usr/bin/sh
export DEBIAN_VERSION=12
export DENO_VERSION=1.43.5
export NODE_VERSION=22.16.0
export MONGO_VERSION=7.0.28
export MONGOSH_VERSION=2.4.2
export ROCKETCHAT_VERSION=7.10.3
mkdir /tmp/work
cd /tmp/work
apt-get update
apt-get upgrade
apt-get install --no-install-suggests --no-install-recommends -y ca-certificates python3 unzip curl libcurl4 libgssapi-krb5-2 libldap-common libwrap0 libsasl2-2 libsasl2-modules libsasl2-modules-gssapi-mit openssl liblzma5 build-essential graphicsmagick

curl https://dl.deno.land/release/v${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip > deno-${DENO_VERSION}.zip
unzip deno-${DENO_VERSION}.zip
cp deno /usr/local/bin

curl https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz > node-v${NODE_VERSION}-linux-x64.tar.xz
tar -xf node-v${NODE_VERSION}-linux-x64.tar.xz
cd node-v${NODE_VERSION}-linux-x64
rm CHANGELOG.md README.md LICENSE
cp -r * /usr/local
cd /tmp/work

curl https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-debian${DEBIAN_VERSION}-${MONGO_VERSION}.tgz > mongodb-linux-x86_64-debian${DEBIAN_VERSION}-${MONGO_VERSION}.tgz
tar -zxf mongodb-linux-x86_64-debian${DEBIAN_VERSION}-${MONGO_VERSION}.tgz
cd mongodb-linux-x86_64-debian${DEBIAN_VERSION}-${MONGO_VERSION}
rm bin/install_compass
cp -r bin /usr/local
cd /tmp/work
mkdir -p /var/log/mongodb
mkdir -p /var/lib/mongodb

curl -L https://github.com/mongodb-js/mongosh/releases/download/v${MONGOSH_VERSION}/mongosh-${MONGOSH_VERSION}-linux-x64.tgz > mongosh-${MONGOSH_VERSION}-linux-x64.tgz
tar -zxf mongosh-${MONGOSH_VERSION}-linux-x64.tgz
cd mongosh-${MONGOSH_VERSION}-linux-x64
cp bin/mongosh /usr/local/bin
cp bin/mongosh_crypt_v1.so /usr/local/lib
gunzip mongosh.1.gz
cp mongosh.1 /usr/share/man/man1/mongosh.1
cd /tmp/work

curl -L https://releases.rocket.chat/${ROCKETCHAT_VERSION}/download > rocketchat-${ROCKETCHAT_VERSION}.tgz
mkdir rocketchat-${ROCKETCHAT_VERSION}
tar -zxf rocketchat-${ROCKETCHAT_VERSION}.tgz -C rocketchat-${ROCKETCHAT_VERSION}
cd rocketchat-${ROCKETCHAT_VERSION}/bundle/programs/server
npm install
cd /tmp/work
cp -r rocketchat-${ROCKETCHAT_VERSION}/bundle/ /opt/rocketchat

useradd -M rocketchat
usermod -L rocketchat
chown -R rocketchat:rocketchat /opt/rocketchat
chown -R rocketchat:rocketchat /var/lib/mongodb
chown -R rocketchat:rocketchat /var/log/mongodb
cp ~/testing/rocketchat.service /lib/systemd/system/rocketchat.service
cp ~/testing/mongod.service /lib/systemd/system/mongod.service
cp ~/testing/mongod.conf /etc/mongod.conf
cp ~/testing/init_container /usr/bin/init_container
chmod 755 /usr/bin/init_container

cd /
rm -rf /tmp/work
