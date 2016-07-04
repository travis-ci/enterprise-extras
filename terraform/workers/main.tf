# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Our default security group to access
# the worker instances over SSH
resource "aws_security_group" "travis-enterprise-workers" {
  name = "travis-enterprise-workers"
  description = "Travis Enterprise Workers"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "workers" {
  instance_type = "c3.xlarge"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  security_groups = ["${aws_security_group.travis-enterprise-workers.name}"]
  key_name = "${var.aws_key_name}"
  count = "${var.worker_count}"

  tags {
    Name = "travis-enterprise-worker"
  }

  user_data = <<USER_DATA
#!/bin/bash
TRAVIS_ENTERPRISE_HOST="${var.enterprise_host_name}"
TRAVIS_ENTERPRISE_SECURITY_TOKEN="${var.rabbitmq_password}"
sed -i "s/\# export TRAVIS_ENTERPRISE_HOST=\"enterprise.yourhostname.corp\"/export TRAVIS_ENTERPRISE_HOST=\"$TRAVIS_ENTERPRISE_HOST\"/" /etc/default/travis-enterprise
sed -i "s/\# export TRAVIS_ENTERPRISE_SECURITY_TOKEN=\"abcd1234\"/export TRAVIS_ENTERPRISE_SECURITY_TOKEN=\"$TRAVIS_ENTERPRISE_SECURITY_TOKEN\"/" /etc/default/travis-enterprise
USER_DATA
}
