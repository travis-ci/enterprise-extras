# Travis CI Enterprise Extras

## Worker Goodies

Setting up a Travis CI Enterprise Worker should never be a hassle. Why shouldn't it be only sunshine, rainbows and unicorns.

To make life easier for you, we have created an AMI with the following goodies baked in:
  - uses the latest Worker application version.
  - uses the latest version of Docker.
  - uses DeviceMapper with LVM storage (like what we use in production).
  - uses libcontainer, and not LXC.
  - downloads all Docker images on boot, which is required as instance storage is used.

The current AMIs supplied by Travis CI are:

- **eu-west-1**: `ami-17dfba64`
- **us-east-1**: `ami-dffe7bc8`
- **us-west-1**: `ami-5fa0e73f`


### Building a new Worker AMI

If you want to build your own AMI you can use the included `worker.json` in the `worker` directory as a template to start from.

Then you can build your new AMI using either:

```
packer build -var-file=config.json worker.json
```
or
```
packer build \
  -var 'aws_access_key=[key]' \
  -var 'aws_access_key=[secret]' \
  worker.json
```

The current Packer config allows for the following options:
- *aws_access_key* the AWS access key to use.
- *aws_secret_key* the AWS access secret matched with the access key.
- *aws_region* (optional, default: us-east-1) which AWS region to use.
- *aws_ami_groups* (optional) if you want to make the AMI public, set this to "all".
- *aws_ami_regions* (optional) which regions to copy the AMI to.
- *travis_extra_vars* (optional) extra vars which are passed to the Worker provisioning script.

If you would like to limit which Build Environment images should be installed, this can be done via:
```
{
  ...
  "travis_extra_vars": "--travis_lang_images=\"ruby jvm node-js\""
}
```

### Starting an Worker instance (AWS CLI)

You can start up a fully working instance using the command below:

```
aws ec2 run-instances \
  --image-id ami-dffe7bc8 \
  --instance-type c3.xlarge \
  --count [num-of-instances] \
  --key-name [key-name] \
  --user-data file://user_data.sh
```

You may notice that included in the command is a reference to a `user_data.sh` file which is also in this repo. This file is used to set the correct details for the worker to connect to your Enterprise Platform.

As a small bonus, you can also start a new worker instance, and tag it at the same time, using the following command:

```
aws ec2 create-tags \
  --resources `aws ec2 run-instances \
    --image-id ami-a340f9b4 \
    --instance-type c3.xlarge \
    --count [num-of-instances] \
    --key-name [key-name] \
    --user-data file://user_data.sh \
    | jq -r '.Instances | map(.InstanceId) | join(" ")'` \
  --tags "Key=Name,Value=travis-enterprise-worker"
```

### Starting an Worker instance (terraform)

We have also supplied the beginnings of some Terraform configs which will allow you to get a Worker cluster up and running in minutes. You can find these in the `terraform` directory.

It is recommended you copy `config.tfvars.example` to `config.tfvars`, and add the AWS key name you would like your worker instances to use, as well as the Platform host name, and RabbitMQ password.

You can then have Terraform do its magic by running:

```
terraform apply -var-file=config.tfvars
```


## Platform Goodies

More to come soon.

If you are impatient, you can check out `bootstrap.sh` and `config.env.example`.
