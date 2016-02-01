FROM armhfbuild/java:openjdk-8-jre

# install plugin dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		libzmq3 logrotate \
	&& rm -rf /var/lib/apt/lists/*

# the "ffi-rzmq-core" gem is very picky about where it looks for libzmq.so
RUN mkdir -p /usr/local/lib \
	&& ln -s /usr/lib/*/libzmq.so.3 /usr/local/lib/libzmq.so

# grab gosu for easy step-down from root
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN arch="$(dpkg --print-architecture)" \
	&& set -x \
	&& curl -o /usr/local/bin/gosu -fsSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$arch" \
	&& curl -o /usr/local/bin/gosu.asc -fsSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$arch.asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

# https://www.elastic.co/guide/en/logstash/2.0/package-repositories.html
# https://packages.elasticsearch.org/GPG-KEY-elasticsearch
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4

ENV LOGSTASH_MAJOR 2.1
ENV LOGSTASH_VERSION 2.1.1-1
ENV LOGSTASH_REPO_BASE http://packages.elasticsearch.org/logstash/${LOGSTASH_MAJOR}/debian

RUN curl -fsSL $LOGSTASH_REPO_BASE/pool/main/l/logstash/logstash_${LOGSTASH_VERSION}_all.deb -o logstash.deb\
	&& dpkg -i logstash.deb \
	&& rm logstash.deb

COPY libjffi-1.2.so /opt/logstash/vendor/jruby/lib/jni/arm-Linux/

# http://aspectized.com/2015/11/elasticsearch-2-stack-on-odroid-ubuntu-15/
#
# RUN mkdir /build-jffi && cd /build-jffi \
# 	&& apt-get update && apt-get install -y git ant \
#   && git clone https://github.com/jnr/jffi.git . \
# 	&& ant jar
#
#   && cp ./build/libjffi-1.2.so /opt/logstash/vendor/jruby/lib/jni/arm-Linux/


ENV PATH /opt/logstash/bin:$PATH

COPY docker-entrypoint.sh /
COPY logstash-simple.conf /etc/logstash/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["logstash", "agent", "--config", "/etc/logstash/logstash-simple.conf"]
