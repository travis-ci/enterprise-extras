variable "prefix" {
  default = "travis-enterprise"
}
variable "env" {
  default = "production"
}

variable "aws_region" {
  default = "us-east-1"
}
variable "aws_az" {
  default = "b"
}

# standard Ubuntu 14.04 AMI
# https://cloud-images.ubuntu.com/locator/ec2/
# Instance Type => hvm:ebs
variable "aws_bastion_amis" {
  default = {
    "eu-central-1" = "ami-1ac73275"
    "eu-west-1" = "ami-be81e0cd"
    "us-east-1" = "ami-cbdd50dc"
    "us-west-1" = "ami-46da9c26"
  }
}

# AWS NAT instance.
# http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_NAT_Instance.html#basics
# aws ec2 describe-images \
#   --owner amazon \
#   --region eu-central-1 \
#   --filters "Name=name,Values=*ami-vpc-nat*" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" "Name=description,Values=*2016*"
variable "aws_nat_amis" {
  default = {
    "eu-central-1" = "ami-5825cd37"
    "eu-west-1" = "ami-a8dd45db"
    "us-east-1" = "ami-4868ab25"
    "us-west-1" = "ami-407f0520"
  }
}

variable "aws_worker_amis" {
  default = {
    "eu-central-1" = "ami-1906ec76"
    "eu-west-1" = "ami-f7583f84"
    "us-east-1" = "ami-3fff7928"
    "us-west-1" = "ami-f52c6a95"
  }
}

variable "ssh_key_name" {
  description = "The AWS key to install on the Bastion, NAT and all Workers."
}

variable "workers_count" {
  default = 3
}

variable "enterprise_host_name" {
  description = "The fully qualified hostname of the Travis Enterprise Platform."
}

variable "rabbitmq_password" {
  description = "The password of the Enterprise Platform RabbitMQ."
}
