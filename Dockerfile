# FROM jenkins/jenkins:alpine
FROM alpine:3.12

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories &&\
  apk update &&\
  apk add --no-cache \
    bash \
    coreutils \
    curl \
    git \
    git-lfs \
    openssh-client \
    tini \
    ttf-dejavu \
    tzdata \
    unzip \
    jenkins \
    docker \
    ansible
# todo: just install docker-cli and use /var/lib/docker.sock
# These are needed by install-plugins: bash curl unzip

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref

ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
ENV REF $REF

# wcfNote: apk add jenkins already create jenkins.
# Jenkins is run with user `jenkins`, uid = 1000. If you bind mount a volume from the host or a data container, ensure you use the same uid
# RUN mkdir -p $JENKINS_HOME \
#   && chown ${uid}:${gid} $JENKINS_HOME \
#   && addgroup -g ${gid} ${group} \
#   && adduser -h "$JENKINS_HOME" -u ${uid} -G ${group} -s /bin/bash -D ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p ${REF}/init.groovy.d

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
# WARN: the following doesn't work
# ENV JENKINS_UC=https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json

RUN chown -R ${user} "$JENKINS_HOME" "$REF"

# for main web interface:
EXPOSE ${http_port}
# will be used by attached slave agents:
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

# USER ${user}
USER root

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

COPY bin /usr/local/bin/
RUN chmod a+x /usr/local/bin/*

COPY jenkinsPlugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

