#!/bin/bash
. config.env

: ${PLATFORM_HOST:?"Please specify the PLATFORM_HOST"}

## Generate user data for starting up the worker
read -r -d "" user_data << EOF
#!/bin/bash
TRAVIS_ENTERPRISE_HOST="$PLATFORM_HOST"
TRAVIS_ENTERPRISE_SECURITY_TOKEN="$RABBITMQ_PASSWORD"
sed -i "s/\# export TRAVIS_ENTERPRISE_HOST=\"enterprise.yourhostname.corp\"/export TRAVIS_ENTERPRISE_HOST=\"\$TRAVIS_ENTERPRISE_HOST\"/" /etc/default/travis-enterprise
sed -i "s/\# export TRAVIS_ENTERPRISE_SECURITY_TOKEN=\"abcd1234\"/export TRAVIS_ENTERPRISE_SECURITY_TOKEN=\"\$TRAVIS_ENTERPRISE_SECURITY_TOKEN\"/" /etc/default/travis-enterprise
EOF

if [ -z ${WORKER_COUNT+x} ]; then
  WORKER_COUNT=3
fi

if [ -z ${WORKER_AMI+x} ]; then
  WORKER_AMI=ami-a340f9b4
fi

echo
echo "starting $WORKER_COUNT workers"
aws ec2 create-tags \
  --resources `aws ec2 run-instances \
    --image-id $WORKER_AMI \
    --instance-type c3.xlarge \
    --count $WORKER_COUNT \
    --key-name $AWS_KEY_NAME \
    --user-data "$user_data" \
    | jq -r '.Instances | map(.InstanceId) | join(" ")'` \
  --tags "Key=Name,Value=$AWS_TAG_PREFIX-$ENVIRONMENT-worker"
