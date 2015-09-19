FROM armv7/armhf-java8 

ENV LOGSTASH_VERSION 1.5.4
ENV LOGSTASH_SRC_DIR /opt/logstash
ENV DATA_DIR /data

RUN cd /tmp && \
    wget https://download.elastic.co/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz && \
    tar -xzvf ./logstash-${LOGSTASH_VERSION}.tar.gz && \
    mv ./logstash-${LOGSTASH_VERSION} ${LOGSTASH_SRC_DIR} && \
    rm ./logstash-${LOGSTASH_VERSION}.tar.gz

ADD libjffi-1.2.so /opt/libjffi-1.2.so
ADD logstash-simple.conf /data/logstash-simple.conf

RUN apt-get update && apt-get install -y zip && apt-get clean
RUN mkdir -p /opt/logstash/vendor/jruby/lib/jni/arm-Linux
RUN cp /opt/libjffi-1.2.so /opt/logstash/vendor/jruby/lib/jni/arm-Linux 
RUN zip -g /opt/logstash/vendor/jruby/lib/jruby.jar /opt/libjffi-1.2.so

WORKDIR /data

VOLUME ${DATA_DIR}

EXPOSE 9292

CMD ["/opt/logstash/bin/logstash", "agent", "-f", "logstash-simple.conf"]
