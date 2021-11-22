FROM openjdk:11-jdk
ENV LTO_LOG_LEVEL="INFO"
ENV LTO_HEAP_SIZE="2g"
ENV LTO_CONFIG_FILE="/lto/configs/lto-config.conf"

# Install python
RUN apt-get update -y && apt-get install -y python3 \
    python3-pip curl \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip && apt install -y libleveldb-java libleveldb-api-java

RUN pip3 install requests pyhocon pywaves==0.8.19 tqdm

COPY lto-public-all.jar /lto-node-temp/
WORKDIR /lto-node-temp
RUN jar -xvf lto-public-all.jar && rm -f lto-public-all.jar && cp META-INF/MANIFEST.MF . \
    && rm -rf `find . -name *leveldb*` && cp /usr/share/java/leveldb-api.jar . && cp /usr/share/java/leveldb.jar . \
    && jar -xvf leveldb-api.jar && jar -xvf leveldb.jar && rm -f *.jar && cp MANIFEST.MF META-INF/ \
    && jar -cfm lto-public-all.jar META-INF/MANIFEST.MF * && mkdir /lto-node && mv lto-public-all.jar /lto-node/lto-public-all.jar
WORKDIR /
RUN rm -rf /lto-node-temp
COPY starter.py /lto-node/
COPY entrypoint.sh /lto-node/
COPY lto-*.conf /lto-node/

VOLUME /lto
EXPOSE 6869 6868 6863
ENTRYPOINT ["/lto-node/entrypoint.sh"]
