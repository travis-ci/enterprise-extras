
variable "aws_region" {
  description = "The AWS region to create things in."
  default = "us-east-1"
}

# Travis Enterprise Worker AMIs
# using Ubuntu Trusty 14.04 LTS (x64)
variable "aws_amis" {
  default = {
    "us-east-1" = "ami-a340f9b4"
  }
}

variable "aws_key_name" {
  description = "The AWS SSH name for sshing into the workers."
}

variable "platform_count" {
  description = "The number of Platform instances to start."
  default = 3
}

variable "enterprise_host_name" {
  description = "The fully qualified hostname of the Travis Enterprise Platform."
}

variable "rabbitmq_password" {
  description = "The password of the Enterprise Platform RabbitMQ."
}
