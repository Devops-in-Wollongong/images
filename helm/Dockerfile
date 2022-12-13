ARG BASE_IMAGE=docker.io/library/centos:latest
FROM $BASE_IMAGE

USER root

RUN sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-* && \
    sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-* && \
    curl -OL https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz && \
    tar -zxvf helm-v3.10.2-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm helm-v3.10.2-linux-amd64.tar.gz && rm -fr linux-amd64 && \
    yum install jq -y

ENTRYPOINT ["sh", "-c", "tail -f /dev/null"]