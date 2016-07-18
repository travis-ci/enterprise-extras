resource "aws_subnet" "public" {
    vpc_id = "${var.aws_vpc_id}"
    cidr_block = "${var.aws_public_subnet}"
    availability_zone = "${var.aws_region}${var.aws_az}"
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.prefix}-${var.env}-public"
    }
}

resource "aws_route_table" "public" {
    vpc_id = "${var.aws_vpc_id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${var.aws_gateway_id}"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = "${aws_subnet.public.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.nat.id}"
    vpc = true
    depends_on = ["aws_route_table.public"]
}

resource "aws_security_group" "nat" {
    name = "${var.prefix}-${var.env}-public-nat"
    description = "Travis CI Enterprise NAT Security Group for Public VPC"
    vpc_id = "${var.aws_vpc_id}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [
            "${aws_subnet.public.cidr_block}",
            "${aws_subnet.workers.cidr_block}",
        ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "nat" {
    ami = "${var.aws_nat_ami}"
    instance_type = "${var.aws_nat_instance_type}"
    vpc_security_group_ids = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.public.id}"
    key_name = "${var.ssh_key_name}"
    tags = {
        Name = "${var.prefix}-${var.env}-nat"
    }
    source_dest_check = false
}
