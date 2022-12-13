FROM ubuntu:latest

USER root
WORKDIR /wait

COPY wait.sh .
RUN apt update && apt install netcat -y &&  apt install curl -y &&  apt install jq -y

ENTRYPOINT ["/bin/bash", "wait.sh"]