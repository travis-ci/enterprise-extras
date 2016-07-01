# Travis CI Enterprise Worker Extras

Setting up a Travis CI Enterprise Worker should never be a hassle. Why shouldn't it be only sunshine, rainbows and unicorns.

To make life easier for you, we have created an AMI with the following goodies baked in:
  - uses the latest Worker application version.
  - uses the latest version of Docker.
  - uses DeviceMapper with LVM storage (like what we use in production).
  - uses libcontainer, and not LXC.
  - downloads all Docker images on boot, which is required as instance storage is used.

Also, if you want to build you own AMI, you can use the supplied Packer template.


## Building a new AMI

If you want to build your own AMI you can use the included `worker.json` as a template to start from.

For example, if you don't want all the build environment images to be download, you can change the following line in the `worker.json` file from:

```
"sudo bash /tmp/installer --aws=true --ami_build=true"
```

to:

```
"sudo bash /tmp/installer --aws=true --ami_build=true --travis_lang_images=\"ruby jvm node-js\""
```

Then you can build your new AMI using:

```
AWS_ACCESS_KEY="[aws_key]" AWS_SECRET_KEY="[aws_secret]" packer build worker.json
```


## Starting an Worker instance

The current latest AMI id is `ami-a340f9b4`. You can start up a fully working instance using the command below:

```
aws ec2 run-instances \
  --image-id ami-a340f9b4 \
  --instance-type c3.xlarge \
  --key-name [key-name] \
  --user-data file://user_data.sh
```

You may notice that included in the command is a reference to a `user_data.sh` file which is also in this repo. This file is used to set the correct details for the worker to connect to your Enterprise Platform.

As a small bonus, you can also start a new worker instance, and tag it at the same time, using the following command:

```
aws ec2 create-tags \
  --resources `aws ec2 run-instances \
    --image-id ami-a340f9b4 \
    --key-name [key-name] \
    --instance-type c3.xlarge \
    --user-data file://user_data.sh \
    | jq -r ".Instances[0].InstanceId"` \
  --tags "Key=Name,Value=travis-enterprise-worker"
```
