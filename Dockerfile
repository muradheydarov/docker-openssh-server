FROM ghcr.io/linuxserver/baseimage-alpine:3.12

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENSSH_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"
ENV PYTHONUNBUFFERED=1

RUN \
 echo "**** install runtime packages ****" && \
 apk add --no-cache --upgrade \
        curl \
        logrotate \
        nano \
        sudo && \
 echo "**** install openssh-server ****" && \
 if [ -z ${OPENSSH_RELEASE+x} ]; then \
        OPENSSH_RELEASE=$(curl -s http://dl-cdn.alpinelinux.org/alpine/v3.12/main/x86_64/ \
        | awk -F '(openssh-server-|.apk)' '/openssh-server.*.apk/ {print $2; exit}'); \
 fi && \
 apk add --no-cache \
        openssh-server==${OPENSSH_RELEASE} \
        openssh-sftp-server==${OPENSSH_RELEASE} && \
 echo "**** setup openssh environment ****" && \
 sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
 usermod --shell /bin/bash abc && \
 rm -rf \
        /tmp/* \
 echo "**** install Python ****" && \
 apk add --no-cache python2 && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    rm -r /root/.cache
# add local files
COPY /root /
