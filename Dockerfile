FROM jenkins/jenkins:alpine

COPY jenkinsPlugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

USER root
RUN sudo apk add -U docker ansible git git-lfs
USER jenkins

