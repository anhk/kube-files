#!/bin/bash

helm list -n middleware | grep -w middleware
if [ $? = 0 ]; then ACTION=upgrade; else ACTION=install; fi

helm $ACTION middleware -n middleware ./ \
  --set mysql.enable=true