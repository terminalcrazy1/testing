FROM debian:bookworm
CMD init_container
ENV DEBIAN_VERSION=12
ENV DENO_VERSION=1.43.5
ENV NODE_VERSION=22.16.0
ENV MONGO_VERSION=7.0.28
ENV MONGOSH_VERSION=2.4.2
ENV ROCKETCHAT_VERSION=7.10.3
RUN mkdir /tmp/work
WORKDIR /tmp/work
RUN apt-get update
RUN apt-get upgrade
RUN apt-get install --no-install-suggests --no-install-recommends -y ca-certificates python3 unzip curl libcurl4 libgssapi-krb5-2 libldap-common libwrap0 libsasl2-2 libsasl2-modules libsasl2-modules-gssapi-mit openssl liblzma5 build-essential graphicsmagick

RUN curl https://dl.deno.land/release/v${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip > deno-${DENO_VERSION}.zip
RUN unzip deno-${DENO_VERSION}.zip
RUN cp deno /usr/local/bin

RUN curl https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz > node-v${NODE_VERSION}-linux-x64.tar.xz
RUN tar -xf node-v${NODE_VERSION}-linux-x64.tar.xz
WORKDIR node-v${NODE_VERSION}-linux-x64
RUN rm CHANGELOG.md README.md LICENSE
RUN cp -r * /usr/local
WORKDIR /tmp/work

RUN curl https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-debian${DEBIAN_VERSION}-${MONGO_VERSION}.tgz > mongodb-linux-x86_64-debian${DEBIAN_VERSION}-${MONGO_VERSION}.tgz
RUN tar -zxf mongodb-linux-x86_64-debian${DEBIAN_VERSION}-${MONGO_VERSION}.tgz
WORKDIR mongodb-linux-x86_64-debian${DEBIAN_VERSION}-${MONGO_VERSION}
RUN rm bin/install_compass
RUN cp -r bin /usr/local
WORKDIR /tmp/work
RUN mkdir -p /var/log/mongodb
RUN mkdir -p /var/lib/mongodb

RUN curl -L https://github.com/mongodb-js/mongosh/releases/download/v${MONGOSH_VERSION}/mongosh-${MONGOSH_VERSION}-linux-x64.tgz > mongosh-${MONGOSH_VERSION}-linux-x64.tgz
RUN tar -zxf mongosh-${MONGOSH_VERSION}-linux-x64.tgz
WORKDIR mongosh-${MONGOSH_VERSION}-linux-x64
RUN cp bin/mongosh /usr/local/bin
RUN cp bin/mongosh_crypt_v1.so /usr/local/lib
RUN gunzip mongosh.1.gz
RUN cp mongosh.1 /usr/share/man/man1/mongosh.1
WORKDIR /tmp/work

RUN curl -L https://releases.rocket.chat/${ROCKETCHAT_VERSION}/download > rocketchat-${ROCKETCHAT_VERSION}.tgz
RUN mkdir rocketchat-${ROCKETCHAT_VERSION}
RUN tar -zxf rocketchat-${ROCKETCHAT_VERSION}.tgz -C rocketchat-${ROCKETCHAT_VERSION}
WORKDIR rocketchat-${ROCKETCHAT_VERSION}/bundle/programs/server
RUN npm install
WORKDIR /tmp/work
RUN cp -r rocketchat-${ROCKETCHAT_VERSION}/bundle/ /opt/rocketchat

RUN useradd -M rocketchat
RUN usermod -L rocketchat
RUN chown -R rocketchat:rocketchat /opt/rocketchat
RUN chown -R rocketchat:rocketchat /var/lib/mongodb
RUN chown -R rocketchat:rocketchat /var/log/mongodb
COPY rocketchat.service /lib/systemd/system/rocketchat.service
COPY mongod.service /lib/systemd/system/mongod.service
COPY mongod.conf /etc/mongod.conf
COPY init_container /usr/bin/init_container
COPY systemctl /usr/bin/systemctl
COPY journalctl /usr/bin/journalctl
RUN chmod 755 /usr/bin/init_container
RUN chmod 755 /usr/bin/systemctl
RUN chmod 755 /usr/bin/journalctl

WORKDIR /
RUN rm -rf /tmp/work
