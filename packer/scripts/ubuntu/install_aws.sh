#!/bin/bash -e

mkdir -p /home/amazon/.aws

echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> /home/amazon/.profile
echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> /home/amazon/.profile
echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> /home/amazon/.profile
cat << EOF > /home/amazon/.aws/config
[default]
region = us-east-2
EOF

cat << EOF > /home/amazon/.aws/credentials
[default]
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
aws_access_key_id = $AWS_ACCESS_KEY_ID
EOF

mkdir -p /root/.aws
echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> /root/.profile
echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> /root/.profile
echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> /root/.profile
cat << EOF > /root/.aws/config
[default]
region = us-east-2
EOF

cat << EOF > /root/.aws/credentials
[default]
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
aws_access_key_id = $AWS_ACCESS_KEY_ID
EOF

# The awscli package for ubuntu is too old, we need to install via pip
#apt-get install -y awscli
apt-get install -y python-pip
pip install --force awscli
curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
chmod +x /usr/local/bin/ecs-cli

# We used to run this script from rc.local but sometimes when this script runs 
# at boot time the ec2 tags aren't yet available, so we'll load it in a 
# service that retries indefinitely on failure and eventually it will work.
# 
# Thesingle quotes around EOF so it won't try to expand the $MAINPID when 
# it runs
mkdir -p /root/bin
mv /var/tmp/update_route53_mapping.sh /root/bin
chmod 755 /root/bin/update_route53_mapping.sh
cat << 'EOF' > /etc/systemd/system/update_route53_mapping.service
[Unit]
Description=Update Route53 Mapping
After=network.target auditd.service

[Service]
StartLimitInterval=0
RestartSec=5
StandardOutput=journal
StandardError=journal
ExecReload=/usr/bin/kill -HUP $MAINPID
KillSignal=SIGQUIT
KillMode=mixed
RemainAfterExit=yes
Restart=on-failure
User=root
ExecStartPre=/bin/echo "Running update_route53_mapping.sh"
ExecStart=/root/bin/update_route53_mapping.sh
ExecStop=/bin/true

[Install]
WantedBy=multi-user.target
EOF

systemctl enable update_route53_mapping
