#!/bin/bash

docker pull datastax/dse-server:6.7.3 || exit 1
docker run -e DS_LICENSE=accept --memory 4g --name my-dse -d datastax/dse-server:6.7.3 -g -s -k || exit 1
echo "Waiting for cassandra to be ready"
while ! docker exec my-dse nodetool status;  do
  sleep 1
done
echo "Cassandra is ready"

cat << EOF > /home/amazon/cqlsh.script
create keyspace ycsb WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor': 3 };
USE ycsb;
create table usertable ( y_id varchar primary key, field0 varchar, field1 varchar, field2 varchar, field3 varchar, field4 varchar, field5 varchar, field6 varchar, field7 varchar, field8 varchar, field9 varchar);
EOF

docker cp /home/amazon/cqlsh.script my-dse:/tmp || exit 1
docker exec -it my-dse cqlsh -f /tmp/cqlsh.script || exit 1
