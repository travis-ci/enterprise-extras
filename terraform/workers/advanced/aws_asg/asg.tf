resource "aws_launch_configuration" "workers" {
    name_prefix = "${var.prefix}-${var.env}-workers-"

    image_id = "${var.aws_worker_ami}"

    instance_type = "c3.2xlarge"

    security_groups = ["${split(",", var.aws_security_groups)}"]

    user_data = "${var.cloud_init}"
    enable_monitoring = false

    key_name = "${var.ssh_key_name}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "workers" {
    name = "${var.prefix}-${var.env}-workers"

    vpc_zone_identifier = ["${split(",", var.aws_workers_subnets)}"]

    desired_capacity = "${var.workers_count}"

    max_size = "${var.workers_count}"
    min_size = 0

    health_check_grace_period = 0
    health_check_type = "EC2"

    launch_configuration = "${aws_launch_configuration.workers.name}"

    default_cooldown = 0

    tag {
        key = "Name"
        value = "${var.prefix}-${var.env}-worker-linux"
        propagate_at_launch = true
    }
    tag {
        key = "env"
        value = "${var.env}"
        propagate_at_launch = true
    }
    tag {
        key = "queue"
        value = "linux"
        propagate_at_launch = true
    }
}
