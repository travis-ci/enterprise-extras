resource "aws_subnet" "workers" {
    vpc_id = "${var.aws_vpc_id}"
    cidr_block = "${var.aws_workers_subnet}"
    availability_zone = "${var.aws_region}${var.aws_az}"
    tags = {
        Name = "${var.prefix}-${var.env}-workers"
    }
}

resource "aws_route_table" "workers" {
    vpc_id = "${var.aws_vpc_id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }
}

resource "aws_route_table_association" "workers" {
    subnet_id = "${aws_subnet.workers.id}"
    route_table_id = "${aws_route_table.workers.id}"
}

resource "aws_security_group" "workers" {
    name = "${var.prefix}-${var.env}-workers-nat"
    description = "NAT Security Group for Travis CI Enterprise Workers VPC"
    vpc_id = "${var.aws_vpc_id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = ["${aws_security_group.bastion.id}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
