#!/bin/bash
. config.env

echo 'finding EC2 security group'
aws ec2 describe-security-groups --group-names $AWS_TAG_PREFIX-$ENVIRONMENT-platform > /dev/null 2>&1

if [ $? != 255 ]
then
  echo "security group found!"
else
  echo "couldn't find a security group, creating one"
  aws ec2 create-security-group --group-name $AWS_TAG_PREFIX-$ENVIRONMENT-platform --description "Travis CI Enteprise Platform Requirements" > /dev/null 2>&1

  for port in 22 80 443 8800 4567 5672
  do
    aws ec2 authorize-security-group-ingress --group-name $AWS_TAG_PREFIX-$ENVIRONMENT-platform \
      --protocol tcp --port $port --cidr 0.0.0.0/0
  done
fi



echo
echo "creating and tagging platform instance"
declare platform_id=`aws ec2 run-instances --image-id $PLATFORM_AMI --instance-type c3.xlarge --security-groups $AWS_TAG_PREFIX-$ENVIRONMENT-platform --key-name $AWS_KEY_NAME --block-device-mappings 'DeviceName=/dev/sda1, Ebs={VolumeSize=50}' | jq -r '.Instances | map(.InstanceId) | join(" ")'`
aws ec2 create-tags \
  --resources $platform_id \
  --tags "Key=Name,Value=$AWS_TAG_PREFIX-$ENVIRONMENT-platform"
echo "created platform instance ($platform_id)"
echo

echo "waiting for the instance to come up, please wait a minute (or two)"
sleep 120



echo "retrieving the hostname"
declare platform_host=`aws ec2 describe-instances --instance-ids $platform_id | jq -r '.Reservations[].Instances[].PublicDnsName'`
echo "=> $platform_host"

echo "starting the platform provisioning process (sit back and relax)"
ansible-playbook ../ansible/platform/travis.yml \
  -i ../ansible/platform/main \
  -u ubuntu \
  --extra-vars "travis-enterprise ansible_ssh_host=$platform_host github_type=$GITHUB_TYPE github_host=$GITHUB_HOST github_clientid=$GITHUB_CLIENTID github_clientsecret=$GITHUB_CLIENTSECRET rabbitmq_password=$RABBITMQ_PASSWORD replicated_daemon_token=$REPLICATED_DAEMON_TOKEN replicated_admin_password=$REPLICATED_ADMIN_PASSWORD replicated_license=$REPLICATED_LICENSE" \
  > provisioning.out
echo "provisioning finished, check out provisioning.out for more details"



echo
echo "checking for an ELB to use"
aws elb describe-load-balancers --load-balancer-name $AWS_TAG_PREFIX-$ENVIRONMENT > /dev/null 2>&1
if [ $? != 255 ]
then
  echo "ELB found, adding instance"
  aws elb register-instances-with-load-balancer \
    --load-balancer-name $AWS_TAG_PREFIX-$ENVIRONMENT \
    --instances $platform_id \
    > /dev/null 2>&1
else
  echo "no ELB found"
fi



echo
echo "Time to use your instance!"
