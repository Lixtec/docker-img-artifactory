ARG ARTIFACTORY_VERSION
FROM openjdk:8

MAINTAINER ludovic.terral

ENV ARTIFACTORY_VERSION=${ARTIFACTORY_VERSION:-6.17.0} 
ENV ARTIFACTORY_USER_NAME=artifactory \
    ARTIFACTORY_USER_ID=1030 \
    ARTIFACTORY_HOME=/opt/jfrog/artifactory \
    ARTIFACTORY_DATA=/var/opt/jfrog/artifactory \
    RECOMMENDED_MAX_OPEN_FILES=32000 \
    MIN_MAX_OPEN_FILES=10000 \
    RECOMMENDED_MAX_OPEN_PROCESSES=1024 \
    POSTGRESQL_VERSION=9.4.1212

# Config proxy apt
RUN echo "version à installer :${ARTIFACTORY_VERSION}" && apt update -y && apt upgrade -y && apt install -y nano gosu && apt autoremove -y 


# Fetch and install Artifactory OSS war archive.
RUN mkdir /opt/jfrog/ && curl -L -k -o /opt/jfrog/artifactory.zip https://bintray.com/jfrog/artifactory/download_file?file_path=jfrog-artifactory-oss-${ARTIFACTORY_VERSION}.zip &&\
    unzip -q /opt/jfrog/artifactory.zip  -d /opt/jfrog/ &&\
    mv ${ARTIFACTORY_HOME}*/ ${ARTIFACTORY_HOME}/ && \
    rm -f /opt/jfrog/artifactory.zip && \
    mv ${ARTIFACTORY_HOME}/etc ${ARTIFACTORY_HOME}/etc.orig/ && \
    rm -rf ${ARTIFACTORY_HOME}/logs && \
    ln -s ${ARTIFACTORY_DATA}/etc ${ARTIFACTORY_HOME}/etc && \
    ln -s ${ARTIFACTORY_DATA}/data ${ARTIFACTORY_HOME}/data && \
    ln -s ${ARTIFACTORY_DATA}/logs ${ARTIFACTORY_HOME}/logs && \
    ln -s ${ARTIFACTORY_DATA}/backup ${ARTIFACTORY_HOME}/backup && \
    ln -s ${ARTIFACTORY_DATA}/access ${ARTIFACTORY_HOME}/access


# Copy entrypoint files
COPY resources/entrypoint-artifactory.sh /
COPY resources/jdbc_drivers/* /opt/jfrog/artifactory/tomcat/lib/
RUN chmod +x /entrypoint-artifactory.sh


# Default mounts. Should be passed in `docker run` or in docker-compose
VOLUME ${ARTIFACTORY_DATA}

# Expose Tomcat's port
EXPOSE 8081

# Start the simple standalone mode of Artifactory
ENTRYPOINT /entrypoint-artifactory.sh
