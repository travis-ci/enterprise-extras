resource "aws_eip" "bastion" {
    instance = "${aws_instance.bastion.id}"
    vpc = true
    depends_on = ["aws_route_table.public"]
}

resource "aws_security_group" "bastion" {
    name = "${var.prefix}-${var.env}-bastion"
    description = "Security Group for bastion server for Travis CI Enterprise Workers VPC"
    vpc_id = "${var.aws_vpc_id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "bastion" {
    ami = "${var.aws_bastion_ami}"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
    subnet_id = "${aws_subnet.public.id}"
    key_name = "${var.ssh_key_name}"
    tags = {
        Name = "${var.prefix}-${var.env}-bastion"
    }
    user_data = <<EOF
#cloud-config
hostname: ${var.prefix}-${var.env}-bastion
manage_etc_hosts: true
EOF
}
