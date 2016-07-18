# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Our default security group to access
# the platform instances over SSH, HTTP, HTTPS, 8800, and Rabbit ports
resource "aws_security_group" "travis-enterprise-platforms" {
  name = "travis-enterprise-platforms"
  description = "Travis Enterprise Platform"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8800
    to_port = 8800
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 4567
    to_port = 4567
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5672
    to_port = 5672
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "platforms" {
  instance_type = "c3.xlarge"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  security_groups = ["${aws_security_group.travis-enterprise-platforms.name}"]
  key_name = "${var.aws_key_name}"
  count = "${var.platform_count}"

  tags {
    Name = "travis-enterprise-platform"
  }

  user_data = <<USER_DATA
#!/bin/bash
TRAVIS_ENTERPRISE_HOST="${var.enterprise_host_name}"
TRAVIS_ENTERPRISE_SECURITY_TOKEN="${var.rabbitmq_password}"
sed -i "s/\# export TRAVIS_ENTERPRISE_HOST=\"enterprise.yourhostname.corp\"/export TRAVIS_ENTERPRISE_HOST=\"$TRAVIS_ENTERPRISE_HOST\"/" /etc/default/travis-enterprise
sed -i "s/\# export TRAVIS_ENTERPRISE_SECURITY_TOKEN=\"abcd1234\"/export TRAVIS_ENTERPRISE_SECURITY_TOKEN=\"$TRAVIS_ENTERPRISE_SECURITY_TOKEN\"/" /etc/default/travis-enterprise
USER_DATA
}
