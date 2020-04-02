#!/bin/bash

RETRY_COUNT=5

retry_run_cmd() {
    cmd=$1
    rc=0

    n=0
    until [ $n -ge $RETRY_COUNT ]
    do
        if [ "$verbose" = true ] ; then
            echo "Invocation $n of $cmd"
        fi
        eval "$cmd"
        rc=$?
        if [[ $rc == 0 ]]; then break; fi
        n=$[$n+1]
        sleep 1
    done
    if [[ $rc != 0 ]]; then cleanup_and_fail; fi
    return $rc
}

# This is for i3.16xlarge instances
for ((i=0;i<8;i++)); do
fdisk /dev/nvme${i}n1 << EOF
n
p
1


w
EOF
    
    retry_run_cmd "mkfs.xfs -f /dev/nvme${i}n1p1"
done

sed -i.bak "1,1 s/^/#Commented out because docker server is broken and not server these files and its too much work to fix the packer file right now plus we don't need a docker update as long as the containers start\n#/" /etc/apt/sources.list.d/docker.list
rm -f /var/lib/dpkg/lock
apt-get update -y
# Need nfs-common for mounting EFS volumes
apt-get install -y nfs-common

echo "/dev/nvme0n1p1 /tmp xfs  defaults,pquota,prjquota  0 0" >> /etc/fstab
mount /tmp
chmod 1777 /tmp

install -d -m 700 /mnt/ephemeral
echo "/dev/nvme1n1p1 /mnt/ephemeral xfs  defaults,pquota,prjquota  0 0" >> /etc/fstab
mount /mnt/ephemeral

mkdir -p /mnt/ephemeral/{media,shared,data}

install -d -m 700 /mnt/efs/plex
echo "fs-d4e11aac.efs.us-east-2.amazonaws.com:/ /mnt/efs/plex nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" >> /etc/fstab
mount /mnt/efs/plex

mkdir -p /mnt/ephemeral/shared/download/usenet/{complete,incomplete}
mkdir -p /mnt/ephemeral/shared/download/usenet/complete/{fights,tv,movies}

mkdir /var/lib/plexmediaserver
echo "/dev/nvme2n1p1 /var/lib/plexmediaserver xfs  defaults,pquota,prjquota  0 0" >> /etc/fstab
mount /var/lib/plexmediaserver
