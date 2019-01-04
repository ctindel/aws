#!/usr/bin/env bash

readonly TODAY=$(date '+%Y%m%d')
#ssh-keygen -a 256 -o -t rsa -b 4096 -f "sa-demo-bootkey-${TODAY}.id_rsa" -C "sa-demo-bootkey-${TODAY}@elastic.co"
#ssh-keygen -t rsa -b 4096 -f "sa-demo-bootkey-${TODAY}.id_rsa" -C "sa-demo-bootkey-${TODAY}@elastic.co"
ssh-keygen -t rsa -b 4096 -f "sa-demo-bootkey-20190103.id_rsa" -C "sa-demo-bootkey-20190103@amazon.com"
