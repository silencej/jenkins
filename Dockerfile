# FROM jenkins/jenkins:alpine
FROM alpine

USER root
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories &&\
  apk update &&\
  apk add jenkins docker ansible git git-lfs bash curl unzip
# todo: just install docker-cli and use /var/lib/docker.sock
# These are needed by install-plugins: bash curl unzip
COPY bin /usr/local/bin/
RUN chmod a+x /usr/local/bin/*
# USER jenkins

ENV JENKINS_UC=https://updates.jenkins.io
# WARN: the following doesn't work
# ENV JENKINS_UC=https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json

COPY jenkinsPlugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

