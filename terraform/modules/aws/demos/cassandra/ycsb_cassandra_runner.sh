#!/bin/bash

#YCSB_OUT_LOG_FILE=/tmp/ycsb-out.txt
YCSB_OUT_LOG_FILE=/dev/null
YCSB_MONGO_DIR=/home/elastic/ycsb-mongodb-binding
YCSB_RECORD_COUNT=100000
YCSB_WORKLOADS=("a" "b" "c" "d" "e" "f")
YCSB_WRITE_CONCERNS=("0" "1" )
MONGODB_URL="mongodb://localhost:27017/ycsb?w="

RANDOM=$$$(date +%s)

while :
do
    cd $YCSB_MONGO_DIR
    mongo ycsb --eval "db.dropDatabase()"
    # Pick a random workload just to vary it up each time around
    selected_workload=${YCSB_WORKLOADS[$RANDOM % ${#YCSB_WORKLOADS[@]} ]}
    echo "Selected workload $selected_workload" >> $YCSB_OUT_LOG_FILE
    # Pick a random write concern since beats has a dashboard that shows things
    # for different write concerns
    selected_write_concern=${YCSB_WRITE_CONCERNS[$RANDOM % ${#YCSB_WRITE_CONCERNS[@]} ]}
    echo "Selected write concern $selected_write_concern" >> $YCSB_OUT_LOG_FILE
    url=$MONGODB_URL$selected_write_concern
    ./bin/ycsb load mongodb -s -P workloads/workload$selected_workload -p recordcount=$YCSB_RECORD_COUNT -p mongodb.url=$url -threads 16 >> $YCSB_OUT_LOG_FILE 2>&1
    ./bin/ycsb run mongodb -s -P workloads/workload$selected_workload -p operationcount=$YCSB_RECORD_COUNT -p mongodb.url=$url -threads 4 >> $YCSB_OUT_LOG_FILE 2>&1
    sleep 1
done
