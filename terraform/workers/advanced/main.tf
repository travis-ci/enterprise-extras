# Specify the provider and access details
provider "aws" {
    region = "${var.aws_region}"
}

module "aws_az" {
    source = "./aws_az"

    prefix = "${var.prefix}"
    env = "${var.env}"

    aws_region = "${var.aws_region}"
    aws_az = "${var.aws_az}"

    aws_public_subnet = "10.2.1.0/24"
    aws_workers_subnet = "10.2.2.0/24"
    aws_vpc_id = "${aws_vpc.main.id}"
    aws_gateway_id = "${aws_internet_gateway.gw.id}"

    aws_bastion_ami = "${lookup(var.aws_bastion_amis, var.aws_region)}"
    aws_nat_ami = "${lookup(var.aws_nat_amis, var.aws_region)}"
    aws_nat_instance_type = "c3.large" # c3.8xlarge

    ssh_key_name = "${var.ssh_key_name}"
}

module "aws_asg" {
    source = "./aws_asg"

    prefix = "${var.prefix}"
    env = "${var.env}"

    aws_security_groups = "${module.aws_az.workers_security_group_id}"
    aws_workers_subnets = "${module.aws_az.workers_subnet_id}"

    aws_worker_ami = "${lookup(var.aws_worker_amis, var.aws_region)}"
    cloud_init = "${template_file.cloud_init.rendered}"

    workers_count = "${var.workers_count}"

    ssh_key_name = "${var.ssh_key_name}"
}
