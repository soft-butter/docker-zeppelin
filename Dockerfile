FROM phusion/baseimage:0.9.18

MAINTAINER Joseph Cheng <indiejoseph@gmail.com>

# Install necessary packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      wget \
      git \
      openjdk-7-jdk \
      libfontconfig \
      python-numpy \
      python-pip \
    && \
    apt-get autoremove -y && \
    apt-get clean

# Install Node.js 4.x
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get autoremove -y && \
    apt-get clean

# Set some environment variables
ENV ZEPPELIN_HOME /opt/apache-zeppelin
ENV ZEPPELIN_PORT 8888
ENV PATH $ZEPPELIN_HOME/bin:$PATH

# Build and Install Zeppelin (this is only one fat command to reduce container size)
RUN wget http://mirror.netcologne.de/apache.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz -O /tmp/apache-maven-3.3.9-bin.tar.gz && \
    tar -xzf /tmp/apache-maven-3.3.9-bin.tar.gz -C /tmp
RUN git clone https://github.com/apache/incubator-zeppelin $ZEPPELIN_HOME && cd $ZEPPELIN_HOME
WORKDIR $ZEPPELIN_HOME
RUN git checkout tags/v0.6.0
RUN /tmp/apache-maven-3.3.9/bin/mvn clean package -Pspark-1.6 -Dspark.version=1.6.1 -Ppyspark -Dhadoop.version=2.6.0 -Phadoop-2.6 -DskipTests -Pyarn
RUN rm -fr /tmp/apache* ~/.m2 ~/.node-gyp ~/.npm

# Install python requirments
RUN pip install requests

# Ports for Zeppelin UI and websocket connection
EXPOSE 8888 8889 4040

# Default mode: Execute Zeppelin UI
CMD ["zeppelin.sh"]
