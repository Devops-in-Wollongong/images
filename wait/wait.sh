#!/bin/bash
# wait.sh
#
# Usage:
# e.g.
# sh wait.sh tcp localhost 8080
# sh wait.sh http www.google.com 80
#
set -e
trap exit INT

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'

function echo_with_color {
    printf "$1$2\033[0m\n"
}

function err_exit {
    echo_with_color "${COLOR_RED}" "$1"
    exit 1
}

function success_exit {
    echo_with_color ${COLOR_GREEN} "wait passed"
    exit 0;
}

#
# 指向内部 API 服务器的主机名
APISERVER=https://kubernetes.default.svc
# 服务账号令牌的路径
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
# 读取 Pod 的名字空间
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)
# 读取服务账号的持有者令牌
TOKEN=$(cat ${SERVICEACCOUNT}/token)
# 引用内部证书机构（CA）
CACERT=${SERVICEACCOUNT}/ca.crt
#

TIMEOUT=120 # seconds

# httpGet, path, port, httpHeaders, timeout
# tcpSocket, path, port, timeout
# jobName, timeout
SERVICE_KIND=$1
SERVICE_NAME=$2
SERVICE_PORT=$3
if [[ $# -ge 4 ]]; then
  TIMEOUT=$4
fi

function wait_tcp() {
  for i in `seq $TIMEOUT`; do
    if nc -vtz "$SERVICE_NAME" "$SERVICE_PORT" > /dev/null 2>&1; then
       success_exit
    fi
    sleep 1
  done

  err_exit "launch failed, depended service is not ready..."
}

function wait_http() {
  for i in `seq $TIMEOUT` ; do
    if [[ `curl -m 1 -I -o /devl/null -s -w %{http_code} $SERVICE_NAME:$SERVICE_PORT` == 200 ]]; then
       success_exit
    fi
    sleep 1
  done

  err_exit "launch failed, depended service is not ready..."
}

function wait_job() {
  job_name=$SERVICE_NAME

  for i in `seq $TIMEOUT` ; do
    job=$(curl -m 1 --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" \
                    -X GET ${APISERVER}/apis/batch/v1/namespaces/$NAMESPACE/jobs/$job_name)
    echo "$job"

    if [[ $(echo "$job" | jq ".status.succeeded") == "1" ]]; then
       success_exit
    fi
    sleep 1
  done

  err_exit "launch failed, depended service is not ready..."
}

function main() {
  echo "Wait for dependencies to be ready..."
  echo "service_kind: $SERVICE_KIND, service_name: $SERVICE_NAME, service_port: $SERVICE_PORT, timeout: $TIMEOUT"
  case $SERVICE_KIND in
    "http")
      wait_http
      ;;
    "tcp")
      wait_tcp
      ;;
    "job")
      wait_job
      ;;
  esac
}