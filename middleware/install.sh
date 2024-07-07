#!/bin/bash

helm list -n middleware | grep -w middleware
if [ $? = 0 ]; then ACTION=upgrade; else ACTION=install; fi


helm $ACTION middleware -n middleware ./ \
  --set global.storageClassName=csi-hostpath-fast \
  --set mysql.enabled=true \
  --set redis.enabled=true \
  --set global.antiAffinity=false

  # --set global.nodeSelector.dead=beef