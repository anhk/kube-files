#!/bin/bash

helm list -n middleware | grep -w middleware
if [ $? = 0 ]; then ACTION=upgrade; else ACTION=install; fi


helm $ACTION middleware -n middleware ./ \
  --set mysql.enabled=false \
  --set mysql.storageClassName=csi-hostpath-fast \
  --set mysql.storageSize=10Gi \
  --set redis.enabled=false \
  --set redis.storageClassName=csi-hostpath-fast \
  --set redis.storageSize=2Gi \
  --set etcd.enabled=true \
  --set etcd.storageClassName=csi-hostpath-fast \
  --set etcd.storageSize=4Gi \
  --set global.antiAffinity=false

  # --set global.nodeSelector.dead=beef
